variable "dynamodb_arn" {
  description = "DynamoDB table ARN - used to scope Lambda's write permission"
  type        = string
}

variable "tags" {
  description = "Tags from Locals in infra/main.tf"
  type        = map(string)
}
