resource "aws_dynamodb_table" "remote_state_backend" {
  billing_mode    = "PAY_PER_REQUEST"

  server_side_encryption = "enabled"

  attribute {
    name = "LockID"
    type = "S"
  }
  
  hash_key        = "LockID"
  name            = "${var.name_prefix}-remote-state-backend"
  tags = "${var.input_tags}"
}
