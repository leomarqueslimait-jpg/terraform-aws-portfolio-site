variable "bucket_regional_domain" {
  description = "Regional domain/endpoint of the S3 bucket - used as the CloudFront origin"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID - used to attach the bucket policy"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN - used in the bucket policy condition"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}