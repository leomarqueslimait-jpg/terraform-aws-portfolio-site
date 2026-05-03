variable "domain_name" {
  description = "Custom domain name for the static website"
  type        = string
}

variable "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain - used as the A record target"
  type        = string
}

variable "cloudfront_distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID - required for Route53 alias record"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}