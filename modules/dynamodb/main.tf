resource "aws_dynamodb_table" "contacts" {
  name         = var.contact_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at" #Lambda will include experies_at in record. Dynamodb check this value to know when to delete the record
    enabled        = true
  }

  tags = merge(var.tags, { Name = "portfolio-contacts-table" })
}