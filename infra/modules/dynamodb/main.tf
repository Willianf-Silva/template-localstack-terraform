resource "aws_dynamodb_table" "main" {
  name         = "${var.app_name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = var.sort_key != "" ? var.sort_key : null
  tags         = var.tags

  attribute {
    name = "id"
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.sort_key != "" ? [var.sort_key] : []
    content {
      name = attribute.value
      type = var.sort_key_type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute != "" ? [var.ttl_attribute] : []
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }
}
