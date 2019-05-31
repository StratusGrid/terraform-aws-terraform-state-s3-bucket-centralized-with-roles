output "bucket" {
  description = "bucket friendly name"
  value = "${aws_s3_bucket.remote_state_backend.bucket}"
}

output "dynamodb_table" {
  description = "dynamodb friendly name"
  value = "${aws_dynamodb_table.remote_state_backend.id}"
}

output "kms_default_key_arn" {
  description = "kms key alias arn that is created by default. Use this when just using this for a state bucket and not from other accounts."
  value = "${aws_kms_key.remote_state_backend.arn}"
}

output "kms_default_key_alias_arn" {
  description = "kms key arn that is created by default. Use this when just using this for a state bucket and not from other accounts."
  value = "${aws_kms_alias.remote_state_backend.arn}"
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
