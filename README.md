# Terraform AWS Portfolio Site

## Project Overview

The goal of this project is to mimic a modern workflow of a team working on a static website with full automation, where the same template can be reused across different projects. CloudFront delivers content faster to users in the US, Europe, and South America. The static website contains a contact form — when submitted, API Gateway triggers a Lambda function which stores the submission in a DynamoDB table. Route53 manages the custom domain with automatic DNS validation via ACM.

This project is split into three layers: **Bootstrap**, **Modules**, and **Infrastructure**. Bootstrap is applied once by a DevOps engineer before the pipeline takes over. Modules are reusable building blocks. Infrastructure wires the modules together into the deployed environment.

## Why OIDC and IAM roles live in bootstrap, not as a module

The initial design had OIDC and IAM roles inside `modules/oidc/` called from `infra/`. This created a deadlock — the pipeline needs the roles to exist to run `infra/`, but the roles only exist after `infra/` runs.

Moving them to bootstrap as flat resources (not a module) solves this cleanly:

- **Not a module** — modules make sense when code is reused across multiple callers. OIDC and the two GitHub Actions roles are only ever created once, in one place. A module would add indirection with no benefit.
- **Flat resources in bootstrap** — the OIDC provider and both IAM roles live directly in `bootstrap/main.tf`, created once locally before the pipeline ever runs.
- **Reusability without hardcoding** — instead of passing `static_website_bucket_arn` and `cloudfront_distribution_arn` as inputs (which don't exist at bootstrap time), the bucket name is derived from a local and CloudFront permissions start broad then are tightened to the specific distribution ARN by `infra/` on first apply.
- **Automatic cache invalidation** — every push to main triggers the deploy role to run `cloudfront create-invalidation`, purging only updated objects so users always get the latest version and never stale cached content. This is why the deploy role needs `cloudfront:CreateInvalidation` — scoped first to all distributions in the account, then tightened to the specific distribution after infra creates it.

---

## Architecture

```
User
 └── Route53 (DNS)
      └── CloudFront (CDN - cache + HTTPS)
           ├── S3 (static site files)
           └── API Gateway (contact form)
                └── Lambda (form handler)
                     └── DynamoDB (contact storage)
```

---

## Project Structure

```
terraform-aws-portfolio-site/
├── bootstrap/          # Run once locally before pipeline
├── infra/              # Managed by CI/CD pipeline
├── modules/
│   ├── s3/             # Static site bucket
│   ├── cloudfront/     # CDN + bucket policy
│   ├── route53/        # Domain, ACM certificate, DNS records
│   ├── api_gateway/    # Contact form API
│   ├── lambda/         # Form handler function
│   ├── iam/            # Lambda execution role
│   └── dynamodb/       # Contact form storage
└── .github/
    └── workflows/
        └── deploy.yml  # CI/CD pipeline
```

---

## Bootstrap

Bootstrap is applied **once locally** by a DevOps engineer before the pipeline can run. It creates the foundational resources that the pipeline depends on to authenticate with AWS.

### What bootstrap creates

**S3 state bucket** — stores Terraform state for both bootstrap and infra. Uses `use_lockfile = true` instead of DynamoDB for state locking, storing the lock file directly in S3 alongside the state.

**OIDC Provider** — registers GitHub as a trusted identity provider in AWS. This allows GitHub Actions to authenticate with AWS using short-lived tokens instead of long-lived access keys stored in secrets.

**Role 1 — `github-actions-terraform`** — broad permissions scoped to this project's infrastructure. Used by the Terraform job to run `plan` and `apply` on every push to main.

**Role 2 — `github-actions-deploy`** — minimal permissions. Used by the deploy job to sync site files to S3 and invalidate the CloudFront cache. If this role were ever compromised, an attacker could only touch site files — not infrastructure.

### How OIDC authentication works

```
1. Push to main triggers GitHub Actions
2. GitHub generates a short-lived OIDC token for the repo
3. Pipeline sends token to AWS STS to assume the role
4. AWS verifies the token against two conditions:
   - aud == "sts.amazonaws.com"
   - sub matches your specific repo on the main branch
5. AWS issues temporary credentials (expire after job finishes)
6. Pipeline uses credentials to run Terraform or deploy site
```

No long-lived AWS credentials are stored in GitHub secrets.

### IAM permission scoping

Bootstrap scopes S3 permissions to the site bucket name and tightens CloudFront permissions to the specific distribution ARN on the first `infra/` apply:

```
bootstrap apply  →  CloudFront: all distributions in account (wildcard)
infra apply      →  CloudFront: specific distribution ARN only
```

This is an accepted tradeoff — `cloudfront:CreateInvalidation` is non-destructive, and the broad window is minutes between bootstrap and first infra apply.

---

## Modules

### `modules/s3`

Creates the private static site bucket with all public access blocked. Outputs `bucket_id`, `bucket_arn`, and `bucket_regional_domain_name` which are passed to the CloudFront module.

### `modules/cloudfront`

Creates the CloudFront distribution with an Origin Access Control (OAC) so only CloudFront can read from the private S3 bucket — users never hit S3 directly. Also attaches the bucket policy granting CloudFront access. Outputs `distribution_id`, `distribution_arn`, and `distribution_domain` which are passed to the Route53 and IAM modules.

### `modules/route53`

Creates the ACM certificate with DNS validation, Route53 CNAME records for validation, and A records pointing the apex and `www` domains to CloudFront. The ACM certificate is created in `us-east-1` regardless of the main region, as required by CloudFront.

### `modules/api_gateway`

Creates a REST API with a `/contacts` POST endpoint that proxies to Lambda, and an OPTIONS endpoint for CORS preflight. Deploys to a `prod` stage.

### `modules/lambda`

Packages and deploys the Python contact form handler. Receives form submissions from API Gateway and writes them to DynamoDB.

### `modules/iam`

Creates the Lambda execution role with permissions to write to DynamoDB and publish CloudWatch logs.

### `modules/dynamodb`

Creates the contacts table with TTL enabled on `expires_at` so old submissions are automatically purged.

---

## CI/CD Pipeline

Every push to `main` triggers the GitHub Actions pipeline:

```
Push to main
    ↓
┌─────────────────────────────────┐
│  Job 1: terraform               │
│  assumes github-actions-terraform│
│                                 │
│  terraform init                 │
│  terraform plan                 │
│  terraform apply                │
└─────────────────┬───────────────┘
                  │ needs: terraform
┌─────────────────▼───────────────┐
│  Job 2: deploy                  │
│  assumes github-actions-deploy  │
│                                 │
│  aws s3 sync site/ → S3         │
│  cloudfront create-invalidation │
└─────────────────────────────────┘
```

Job 2 only runs after Job 1 succeeds — site files are never deployed on top of a failed infrastructure apply.

---

## Order of Operations

### First time setup (local)

```bash
# 1. Apply bootstrap
cd bootstrap
terraform apply
terraform output -raw terraform_role_arn   # copy to GitHub secret TERRAFORM_ROLE_ARN
terraform output -raw deploy_role_arn      # copy to GitHub secret DEPLOY_ROLE_ARN

# 2. Add GitHub secrets
TERRAFORM_ROLE_ARN           ← from bootstrap output
DEPLOY_ROLE_ARN              ← from bootstrap output
BUCKET_NAME                  ← from infra output after first apply
CLOUDFRONT_DISTRIBUTION_ID   ← from infra output after first apply

# 3. Initialise infra backend
cd infra
cp backend.hcl.example backend.hcl
# edit backend.hcl with your state bucket name
terraform init -backend-config=backend.hcl
terraform apply

# 4. Add remaining secrets from infra outputs
terraform output -raw s3_bucket_name
terraform output -raw cloudfront_distribution_id
```

### Every push to main after that

The pipeline handles everything automatically.

---

## Reusability

This template is designed to be reused across projects. To deploy for a different project:

1. Fork the repo
2. Run bootstrap with your own `terraform.tfvars`
3. Fill in `infra/terraform.tfvars` and `infra/backend.hcl`
4. Add GitHub secrets
5. Push to main

No hardcoded account IDs, bucket names, or ARNs in the codebase — all environment-specific values are injected via `tfvars` files which are gitignored.

---

## Lessons Learned — Things to Watch Next Time

### IAM scoping vs Terraform's S3 backend behavior

My instinct was to lock down the Terraform role to the exact state file — something like:

```
arn:aws:s3:::projects-tf-state-new/bootstrap-portfolio.../terraform.tfstate
```

Least privilege, clean, makes sense in theory. The problem is that Terraform's S3 backend doesn't just read and write one file. Every time it initializes, it also lists the `env:/` prefix to check for workspaces, and lists the parent prefix to verify the state file exists. All of that is `ListBucket` — and `ListBucket` is a bucket-level permission in AWS. You can't scope it to a single file, only to a prefix.

So the correct split is:
- Object-level actions (`GetObject`, `PutObject`, `DeleteObject`) → scoped to your prefix with `/*`
- `ListBucket` → must be bucket-level, use a prefix condition to limit what it can see, and explicitly allow `env:/*`

The security you actually get comes from scoping the object actions to your prefix — other projects' state files are protected even if the role can list the bucket. `ListBucket` and object access are two separate permission layers in S3 and need to be treated separately.

### Bootstrap changes need a local apply before the pipeline can use them

This one cost a few hours. When you edit IAM policies in `bootstrap/main.tf`, those changes don't reach AWS until you run `terraform apply` locally. The pipeline assumes a role — but it gets whatever policy is actually attached to that role in AWS at that moment, not what's in your local files.

The error (`SignatureDoesNotMatch` → then `AccessDenied`) was misleading because it pointed at credentials and region, not permissions. Next time: if the pipeline is 403ing on S3 and local AWS CLI works fine with the same role, check whether bootstrap was applied after the last IAM change.

The rule going forward:
- `bootstrap/` changes → always apply locally, it controls the roles and state bucket everything else depends on
- `infra/` changes → let the pipeline handle it, that's what it's there for

### OIDC and IAM roles belong in bootstrap, not in a module

The initial design had OIDC and the IAM roles inside `modules/oidc/` called from `infra/`. That created a deadlock — the pipeline needs the roles to exist to run `infra/`, but the roles only exist after `infra/` runs. No way out of that loop.

Moving them to `bootstrap/` as flat resources solved it. I also had to think carefully about the CloudFront permissions — at bootstrap time the distribution doesn't exist yet, so I couldn't scope the IAM policy to a specific ARN. I started broad (all distributions in the account) and tightened it to the specific distribution ARN on the first `infra/` apply. Accepted tradeoff — `cloudfront:CreateInvalidation` is non-destructive and the broad window is only the few minutes between bootstrap and first infra apply.

---

## GitHub Secrets Reference

| Secret | Description |
|---|---|
| `TERRAFORM_ROLE_ARN` | IAM role for Terraform job — from `bootstrap` output |
| `DEPLOY_ROLE_ARN` | IAM role for deploy job — from `bootstrap` output |
| `BUCKET_NAME` | S3 static site bucket name — from `infra` output |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID — from `infra` output |
