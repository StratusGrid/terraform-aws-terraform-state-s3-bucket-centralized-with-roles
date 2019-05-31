This is intended to be used by an organization for all of their own accounts. This does not protect access to DynamoDB locking of other accounts, it only restricts access S3 paths for each account.

This restriction is put in place by creating a unique role for each account, then attaching an assumerole policy that trusts the corresponding account to assume it. You will still need to give permission to assume roles to your users/roles that are used to apply terraform in other accounts, and configure your state appropriately to use this.

## Example Config:
```
module "terraform_state_backend" {
  source = "github.com/StratusGrid/terraform-aws-terraform-state-s3-bucket-centralized-with-roles"
  name_prefix = "mycompany"
  log_bucket_id = "${module.s3_bucket_logging.bucket_id}"
  account_arns = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::098765432109:root"
  ]
  global_account_arns = ["arn:aws:iam::123456789012:root"]
  input_tags = "${local.common_tags}"
}

output "terraform_state_kms_key_alias_arns" {
  value = "${module.terraform_state.kms_key_alias_arns}"
}

output "terraform_state_kms_key_arns" {
  value = "${module.terraform_state.kms_key_arns}"
}

output "terraform_state_iam_role_arns" {
  value = "${module.terraform_state.iam_role_arns}"
}
```

## Example Backend Config:
```
terraform {
  backend "s3" {
    role_arn        = "arn:aws:iam::123456789012:role/123456789012-terraform-state"
    acl             = "bucket-owner-full-control"
    bucket          = "mycompany-remote-state-backend-anm1587s49"
    dynamodb_table  = "mycompany-remote-state-backend"
    encrypt         = true
    key             = "123456789012/mycompany-account-organization-master/terraform.tfstate"
    kms_key_id      = "arn:aws:kms:us-east-1:123456789012:key/4ryh7htp-FAKE-ARNS-DUDE-777d88512345"
    region          = "us-east-1"
  }
}

```

## Example to Initialize the backend:
```
terraform init -backend-config="access_key=AKIAIOIEXAMPLEOXJA" -backend-config="secret_key=PiNMLcNOTAREALKEYGQGzz20v3"
```
NOTE: The access and secret keys used must have rights to assume the role created by the module
- This is usually automatically the case for any keys that have full admin rights in the account whose state is to be stored, or in one of the global accounts specified.
- Otherwise, this will need to be assigned manually. You can use this module to help with mapping those trusts: https://registry.terraform.io/modules/StratusGrid/iam-cross-account-trust-maps/aws
  - Use trusting_arn to map a single trust (like for a standard account assumption policy)
  - Use trusting_arns to map multiple trusts (like for a global account assumption policy)

## Example Configuration on Global Users Account:
```
# This should have each terraform state role if you want a user to be able to apply terraform manually
locals {
  mycompany_organization_terraform_state_account_roles = [
    "arn:aws:iam::123456789012:role/210987654321-terraform-state",
    "arn:aws:iam::123456789012:role/123456789012-terraform-state"
  ]
}

# When require_mfa is set to true, terraform init and terraform apply would need to be run with your STS acquired temporary token
module "mycompany_organization_terraform_state_trust_maps" {
  source = "StratusGrid/iam-role-cross-account-trusting/aws"
  version = "1.1.0"
  trusting_role_arns = "${local.mycompany_organization_terraform_state_account_roles}"
  trusted_policy_name = "mycompany-organization-terraform-states"
  trusted_group_names = [
    "${aws_iam_group.mycompany_internal_admins.name}"
  ]
  trusted_role_names = []
  require_mfa = false
  input_tags = "${local.common_tags}"
}
```

## Example config without trusting any other accounts
In this case, you just don't specific other accounts. Then, you use the default kms key along with the dynamodb table.
```
module "terraform_state" {
  # source = "github.com/StratusGrid/terraform-aws-terraform-state-s3-bucket-centralized-with-roles"
  source  = "StratusGrid/terraform-state-s3-bucket-centralized-with-roles/aws"
  version = "1.0.4"
  name_prefix = "${var.name_prefix}"
  log_bucket_id = "${module.s3_bucket_logging.bucket_id}"
  account_arns = [
  ]
  global_account_arns = []
  input_tags = "${local.common_tags}"
}

output "terraform_state_kms_key_alias_arn" {
  value = "${module.terraform_state.kms_default_key_alias_arn}"
}

output "terraform_state_kms_key_arn" {
  value = "${module.terraform_state.kms_default_key_arn}"
}

```