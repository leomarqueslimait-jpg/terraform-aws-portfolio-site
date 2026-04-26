variable "website_bucket_name" {
  description = "Name of the bucket containing static website"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}