resource "aws_dynamodb_table" "remote_state_backend" {
  billing_mode   = var.dynamodb_table_billing_type
  read_capacity  = var.dynamodb_table_read_capacity
  write_capacity = var.dynamodb_table_write_capacity

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
  name     = "${var.name_prefix}-remote-state-backend${var.name_suffix}"

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.remote_state_backend.arn
  }

  tags = local.common_tags
}
