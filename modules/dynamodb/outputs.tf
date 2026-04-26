output "table_arn" {
  description = "Dynamodb table ARN - used by IAM to grant Lambda write aceess"
  value       = aws_dynamodb_table.contacts.arn
}

output "table_name" {
  description = "DynamoDB table name - passed to Lambda as enviroment variable"
  value       = aws_dynamodb_table.contacts.name
}

