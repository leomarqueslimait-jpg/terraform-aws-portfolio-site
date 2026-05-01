variable "state_bucket_name" {
  description = "Name of the bucket state in bootstrap folder to be used by backend s3"
  type        = string
}

variable "dynamodb_tf_state_lock" {
  description = "Name of the DynamoDB tfstate lock table"
  type = string
}

variable "backend_bucket_key" {
  description = "Key of state file in backend S3 bucket"
  type = string
}

variable "backend_bucket_region" {
  description = "Region of backend bucket"
  type = string
}

