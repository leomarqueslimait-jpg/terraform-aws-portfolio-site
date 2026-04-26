variable "state_bucket_name" {
  description = "Name of the bucket state in bootstrap folder to be used by backend s3"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB lock table in bootstrap folder to be used by backend s3"
  type        = string
}

variable "aws_region" {
  description = "AWS region that will host infrastructure"
  type = string
  default = "us-east-1"
}