variable "github_org" {
  description = "Github username"
  type        = string
}

variable "github_repo" {
  description = "Project's Gihut repository"
  type        = string
}

variable "tfstate_bucket" {
  description = "Terraform state bucket arn"
  type        = string
}


variable "dynamodb_lock_table" {
  description = "Name of DynamoDB lock table"
  type        = string
}

variable "dynamodb_lock_table_region" {
  description = "Region of Dynamodb lock table"
  type        = string
}

variable "tf_state_bucket_key" {
  description = "Full path to state file in S3 e.g. portfolio-website"
  type        = string
}

variable "static_website_bucket_arn" {
  description = "ARN of static website"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of Cloudfront distribution"
  type        = string
}

variable "aws_region" {
  description = "AWS region where infrastructure is deployed"
  type        = string
}

variable "tags" {
  description = "tags from locals in infra/main"
  type        = map(string)
}