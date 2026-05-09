# Tightens Role 1 CloudFront permission to specific distribution ARN
data "aws_iam_policy_document" "terraform_cloudfront_scoped" {
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.cloudfront.distribution_arn]
  }
}

resource "aws_iam_role_policy" "terraform_cloudfront_scoped" {
  name   = "${var.project_name}-github-terraform-cloudfront-scoped"
  role   = "${var.project_name}-github-terraform-role"
  policy = data.aws_iam_policy_document.terraform_cloudfront_scoped.json
}

# Tightens Role 2 CloudFront permission to specific distribution ARN
# Narrows the wildcard set in bootstrap to this project's distribution only
data "aws_iam_policy_document" "deploy_cloudfront_scoped" {
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.cloudfront.distribution_arn]
  }
}

resource "aws_iam_role_policy" "deploy_cloudfront_scoped" {
  name   = "${var.project_name}-deploy-cloudfront-scoped"
  role   = "${var.project_name}-github-deploy-role"
  policy = data.aws_iam_policy_document.deploy_cloudfront_scoped.json

}