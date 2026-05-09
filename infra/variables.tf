

variable "contact_table_name" {
  description = "Name of the DynamoDB contacts table"
  type        = string
}

variable "aws_region" {
  description = "AWS region that will host infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "website_bucket_name" {
  description = "Name of the website"
  type        = string
}

variable "project_name" {
  description = "Name of the project - it has to be the same as in bootstrap"
  type        = string
}
