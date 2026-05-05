data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

# ACM certificate - "provider" must be in us-east-1 for CloudFront
# This provider alias is defined in infra/providers.tf

resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]
  #so, there is always a cert for cloudfront
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "portfolio-cert" })
}


# DNS validation records - proves to AWS you own the domain
# ACM gives you a CNAME record to add to Route53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# This will force terraform to wait for certificate to be validated before proceeding
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

}


# Route53 A record - points domain/alternative names to Cloudfront
resource "aws_route53_record" "apex" {
  for_each = toset([var.domain_name, "www.${var.domain_name}"])
  zone_id  = data.aws_route53_zone.domain.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = var.cloudfront_distribution_domain
    zone_id                = var.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
