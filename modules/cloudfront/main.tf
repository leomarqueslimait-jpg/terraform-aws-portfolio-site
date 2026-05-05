#oac - Original Access control - the key that lets cloudfront read your private S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "portfolio-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  aliases = [var.domain_name, "www.${var.domain_name}"]
  enabled             = true
  default_root_object = "index.html"
  comment             = "Portfolio site CDN"

  origin {
    domain_name              = var.bucket_regional_domain
    origin_id                = "s3-portfolio" #name tag
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-portfolio" #send traffic to this origin
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 86400
    max_ttl = 31536000    

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  #SSL/TLS certificate, whuch is used in the HTTPS. default certificate  from AWS
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  price_class = "PriceClass_200"


  tags = merge(var.tags, { Name = "portfolio-cdn" })
}

data "aws_iam_policy_document" "allow_cloudfront" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${var.bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.allow_cloudfront.json
}