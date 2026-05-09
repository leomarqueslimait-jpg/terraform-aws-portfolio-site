output "tfstate_bucket" {
  description = "Name of the bucket state in bootstrap folder to be used by backend s3"
  value       = var.tfstate_bucket
}

output "github_terraform_role_arn" {
  description = "Paste into GitHub secrets as TERRAFORM_ROLE_ARN"
  value       = aws_iam_role.github_terraform_role.arn
  sensitive   = true
}

output "github_deploy_role_arn" {
  description = "Paste into GitHub secrets as DEPLOY_ROLE_ARN"
  value       = aws_iam_role.github_deploy_role.arn
  sensitive   = true
}

output "website_bucket_name" {
  description = "Name of the site S3 bucket - pass to infra/ as website_bucket_name"
  value       = local.website_bucket_name
}