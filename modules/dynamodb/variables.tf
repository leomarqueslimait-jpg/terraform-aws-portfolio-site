variable "contact_table_name" {
  description = "Name of DynamoDB table fpr contact form submissions"
  type        = string
}

variable "tags" {
  description = "Tags from locals in infra/main.tf"
  type        = map(string)
}
