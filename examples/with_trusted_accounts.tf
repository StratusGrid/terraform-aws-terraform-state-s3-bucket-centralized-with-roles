module "terraform_state_backend" {
  source  = "StratusGrid/terraform-state-s3-bucket-centralized-with-roles/aws"
  version = "~> 3.0"

  name_prefix   = "mycompany"
  log_bucket_id = module.s3_bucket_logging.bucket_id
  account_arns = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::098765432109:root"
  ]
  global_account_arns = ["arn:aws:iam::123456789012:root"]
  input_tags          = local.common_tags
}

output "terraform_state_kms_key_alias_arns" {
  value = module.terraform_state.kms_key_alias_arns
}

output "terraform_state_kms_key_arns" {
  value = module.terraform_state.kms_key_arns
}

output "terraform_state_iam_role_arns" {
  value = module.terraform_state.iam_role_arns
}

