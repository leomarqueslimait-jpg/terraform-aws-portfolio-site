output "lambda_role_arn" {
  description = "IAM role ARN - passed to Lambda so it knows what role to assume"
  value       = aws_iam_role.lambda_role.arn
}