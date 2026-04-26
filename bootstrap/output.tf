output "state_bucket_name" {
  description = "Name of the bucket state in bootstrap folder to be used by backend s3"
  value       = aws_s3_bucket.state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB lock table in bootstrap folder to be used by backend s3"

  value = aws_dynamodb_table.lock.name
}