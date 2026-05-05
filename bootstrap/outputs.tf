output "tfstate_bucket" {
  description = "Name of the bucket state in bootstrap folder to be used by backend s3"
  value       = var.tfstate_bucket
}

output "terraform_role_arn" {
  description = "Paste into GitHub secrets as TERRAFORM_ROLE_ARN"
  value       = aws_iam_role.terraform.arn
  sensitive   = true
}

output "deploy_role_arn" {
  description = "Paste into GitHub secrets as DEPLOY_ROLE_ARN"
  value       = aws_iam_role.github_deploy.arn
  sensitive   = true
}

output "website_bucket_name" {
  description = "Name of the site S3 bucket - pass to infra/ as website_bucket_name"
  value       = local.website_bucket_name
}