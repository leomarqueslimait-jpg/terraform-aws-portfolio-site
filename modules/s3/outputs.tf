output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static_website.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket - used by CloudFront bucket policy"
  value       = aws_s3_bucket.website.arn
}

output "bucket_regional_domain" {
  description = "Regional domain name — used as CloudFront origin"
  value       = aws_s3_bucket.static_website.bucket_regional_domain_name
}