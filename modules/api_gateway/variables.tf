variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN - used by API Gateway to trigger the function"
  type        = string

}

variable "lambda_function_name" {
  description = "Lambda function name - used by API Gateway permission resource"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}