output "acm_certificate_arn" {
  description = "ACM certificate ARN - passed to CloudFront module to enable HTTPS on custom domain"
  value       = aws_acm_certificate.cert.arn
}