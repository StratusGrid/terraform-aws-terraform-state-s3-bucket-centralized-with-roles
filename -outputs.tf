output "bucket" {
  description = "bucket friendly name"
  value = "${aws_s3_bucket.remote_state_backend.bucket}"
}

output "dynamodb_table" {
  description = "dynamodb friendly name"
  value = "${aws_dynamodb_table.remote_state_backend.id}"
}

output "kms_key_alias_arns" {
  description = "kms key alias arns for each specific account"
  value = "${aws_kms_alias.specific_state_backend.*.arn}"
}

output "kms_key_arns" {
  description = "kms key arns for each specific account"
  value = "${aws_kms_key.specific_remote_state_backend.*.arn}"
}

output "iam_role_arns" {
  description = "arns for each IAM role that can be assumend for the corresponding account's terraform state"
  value = "${aws_iam_role.account_state_role.*.arn}"
}
