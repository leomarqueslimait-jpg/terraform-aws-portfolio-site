# Tightens Role 1 CloudFront permission to specific distribution
data "aws_iam_policy_document" "terraform_cloudfront_scoped" {
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.cloudfront.distribution_arn]
  }
}

resource "aws_iam_role_policy" "terraform_cloudfront_scoped" {
  name   = "terraform-cloudfront-scoped"
  role   = "github-actions-terraform"
  policy = data.aws_iam_policy_document.terraform_cloudfront_scoped.json
}

# Tightens Role 2 CloudFront permission to specific distribution
data "aws_iam_policy_document" "deploy_cloudfront_scoped" {
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.cloudfront.distribution_arn]
  }
}

resource "aws_iam_role_policy" "deploy_cloudfront_scoped" {
  name   = "deploy-cloudfront-scoped"
  role   = "github-actions-deploy"
  policy = data.aws_iam_policy_document.deploy_cloudfront_scoped.json
}