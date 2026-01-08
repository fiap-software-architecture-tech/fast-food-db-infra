# ===========================
# DYNAMODB - COOK-TO-ORDER
# ===========================

resource "aws_dynamodb_table" "orders_cook_to_order" {
  name         = "fastfood-orders-cook-to-order"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  tags = {
    Name        = "fastfood-orders-cook-to-order"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}