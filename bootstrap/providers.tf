terraform {
  required_version = "~> 1.14"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = var.state_bucket_name
    key = var.backend_bucket_key
    region = var.backend_bucket_region
    dynamodb_table = var.dynamodb_tf_state_lock
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}