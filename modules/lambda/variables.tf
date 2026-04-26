variable "lambda_role_arn" {
  description = "IAM role ARN - the role Lambda will assume when it runs"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name - passed to Lambda as DYNAMODB_TABLE enviroment variable. Used by the handler to connect to the correct table at runtime"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}