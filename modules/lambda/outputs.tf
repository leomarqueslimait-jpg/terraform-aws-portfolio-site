output "invoke_arn" {
  description = "Lambda invoke ARN - used by API Gateway to trigger the function"
  value       = aws_lambda_function.contact.invoke_arn
}

output "function_name" {
  description = "Lambda function name - used by API Gateway permission resource"
  value       = aws_lambda_function.contact.function_name
}