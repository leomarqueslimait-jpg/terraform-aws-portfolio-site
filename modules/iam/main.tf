resource "aws_iam_role" "lambda_role" {
  name               = "lambda-contact-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = merge(var.tags, { Name = "portfolio-lambda-role" })

}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    actions   = ["dynamodb:PutItem"]
    effect    = "Allow"
    resources = [var.dynamodb_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name   = "lambda-dynamodb-write"
  role   = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

