data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/src"
}

resource "aws_lambda_function" "contact" {
  function_name    = "portfolio-contact-form"
  role             = var.lambda_role_arn
  runtime          = "python3.12"
  handler          = "handler.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }
  tags = merge(var.tags, { Name = "portfolio-contact-function" })
}

