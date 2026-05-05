variable "website_bucket_name" {
  description = "Name of the static site S3 bucket. Must start with the project_name used in bootstrap/ (e.g. if project_name = 'portfolio', bucket name must start with 'portfolio-'). This is required for bootstrap IAM permissions to apply correctly."
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}