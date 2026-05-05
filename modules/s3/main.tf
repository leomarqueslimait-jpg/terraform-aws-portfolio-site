# Bucket name defined in bootstrap/terraform.tfvars at start with project_name defined
resource "aws_s3_bucket" "static_website" {
  bucket = var.website_bucket_name

  tags = merge(var.tags, { Name = "portfolio-static-site" })
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}