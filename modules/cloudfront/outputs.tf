output "distribution_id" {
  description = "CloudFront distribution ID - used to invalidate cache after uploads"
  value       = aws_cloudfront_distribution.cdn.id
}

output "distribution_domain" {
  description = "CloudFront URL - stastic site's public address"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution - used by infra/ to tighten IAM permissions"
  value       = aws_cloudfront_distribution.cdn.arn
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID - used by Route53 alias record"
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}