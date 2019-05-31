resource "aws_kms_key" "remote_state_backend" {
  description         = "Default Key for remote state backend bucket"
  enable_key_rotation = true
  tags = "${var.input_tags}"
}

resource "aws_kms_alias" "remote_state_backend" {
  name          = "alias/${var.name_prefix}-remote-state-backend-default-key${var.name_suffix}"
  target_key_id = "${aws_kms_key.remote_state_backend.key_id}"
}