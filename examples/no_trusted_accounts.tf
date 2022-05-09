module "terraform_state" {
  source  = "StratusGrid/terraform-state-s3-bucket-centralized-with-roles/aws"
  version = "~> 4.0"

  name_prefix   = var.name_prefix
  name_suffix   = local.name_suffix
  log_bucket_id = module.s3_bucket_logging.bucket_id
  account_arns = [
  ]
  global_account_arns = []
  input_tags          = merge(local.common_tags, {})
}

output "terraform_state_kms_key_alias_arn" {
  value = module.terraform_state.kms_default_key_alias_arn
}

output "terraform_state_kms_key_arn" {
  value = module.terraform_state.kms_default_key_arn
}

