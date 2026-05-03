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