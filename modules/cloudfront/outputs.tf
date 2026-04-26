output "distribution_id" {
  description = "CloudFront distribution ID - used to invalidate cache after uploads"
  value       = aws_cloudfront_distribution.cdn.id
}

output "distribution_domain" {
  description = "CloudFront URL - stastic site's public address"
  value       = aws_cloudfront_distribution.cdn.domain_name
}
