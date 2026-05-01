output "cloudfront_url" {
  description = "Website's public URL"
  value = modules.cloudfront.distribution_domain
}

output "api_endpoint" {
  description = "Contact form API URL - paste into index.html as API_ENDPOINT"
  value = modules.api_gateway.endpoint_url
}

output "s3_bucket_name" {
  description = "Name of S3 Bucket - used for sycing site files"
  value = modules.s3.bucket_id
}

output "cloudfront_distribution_id" {
  description = "Cloudfront distribution ID - used for cache invalidtaion"
  value = module.cloudfront.distribution_id
}