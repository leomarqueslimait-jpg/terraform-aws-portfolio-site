variable "github_org" {
  description = "Github username"
  type        = string
}

variable "github_repo" {
  description = "Project's Gihut repository"
  type        = string
}

variable "project_name" {
  description = "Project name used to scope IAM permissions by naming convention (e.g. 'portfolio')"
  type        = string
}

variable "tfstate_bucket" {
  description = "Terraform state bucket arn"
  type        = string
}

variable "tf_state_bucket_key" {
  description = "Full path to state file in S3 e.g. portfolio-website"
  type        = string
}

variable "aws_region" {
  description = "AWS region where infrastructure is deployed"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}