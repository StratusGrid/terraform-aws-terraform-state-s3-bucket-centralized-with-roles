resource "aws_dynamodb_table" "remote_state_backend" {
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
  name     = "${var.name_prefix}-remote-state-backend${var.name_suffix}"
  tags     = local.common_tags
}
