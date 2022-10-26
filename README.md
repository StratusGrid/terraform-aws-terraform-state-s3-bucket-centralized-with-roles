<!-- BEGIN_TF_DOCS -->
# terraform-state-s3-bucket-centralized-with-roles

GitHub: [StratusGrid/terraform-state-s3-bucket-centralized-with-roles](https://github.com/StratusGrid/terraform-state-s3-bucket-centralized-with-roles)

This is intended to be used by an organization for all of their own accounts. This does not protect access to DynamoDB locking of other accounts, it only restricts access S3 paths for each account.

This restriction is put in place by creating a unique role for each account, then attaching an assumerole policy that trusts the corresponding account to assume it. You will still need to give permission to assume roles to your users/roles that are used to apply terraform in other accounts, and configure your state appropriately to use this.

As of v3.0, all public access is blocked by default.  There are individual parameters which can be set to "false" if public bucket/state access is desired:
* block_public_acls
* block_public_policy
* ignore_public_acls
* restrict_public_buckets

## Example Config:

```hcl
module "terraform_state_backend" {
  source  = "StratusGrid/terraform-state-s3-bucket-centralized-with-roles/aws"
  version = "~> 4.1"

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
```

## Example Backend Config:

```hcl
terraform {
  backend "s3" {
    role_arn       = "arn:aws:iam::123456789012:role/123456789012-terraform-state"
    acl            = "bucket-owner-full-control"
    bucket         = "mycompany-remote-state-backend-anm1587s49"
    dynamodb_table = "mycompany-remote-state-backend"
    encrypt        = true
    key            = "123456789012/mycompany-account-organization-master/terraform.tfstate"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/4ryh7htp-FAKE-ARNS-DUDE-777d88512345"
    region         = "us-east-1"
  }
}

```

## Example to Initialize the backend:
```
terraform init -backend-config="access_key=ABCDEFGHIJKLMNOPQR" -backend-config="secret_key=AbcDeFgHIJKlmnOPqRStUVwxyZ"
```

NOTE: The access and secret keys used must have rights to assume the role created by the module
- This is usually automatically the case for any keys that have full admin rights in the account whose state is to be stored, or in one of the global accounts specified.
- Otherwise, this will need to be assigned manually. You can use this module to help with mapping those trusts: https://registry.terraform.io/modules/StratusGrid/iam-cross-account-trust-maps/aws
- Use trusting_arn to map a single trust (like for a standard account assumption policy)
- Use trusting_arns to map multiple trusts (like for a global account assumption policy)

## Example Configuration on Global Users Account:

```hcl
# This should have each terraform state role if you want a user to be able to apply terraform manually
locals {
  mycompany_organization_terraform_state_account_roles = [
    "arn:aws:iam::123456789012:role/210987654321-terraform-state",
    "arn:aws:iam::123456789012:role/123456789012-terraform-state"
  ]
}

# When require_mfa is set to true, terraform init and terraform apply would need to be run with your STS acquired temporary token
module "mycompany_organization_terraform_state_trust_maps" {
  source              = "StratusGrid/iam-role-cross-account-trusting/aws"
  version             = "~> 2.1"
  trusting_role_arns  = local.mycompany_organization_terraform_state_account_roles
  trusted_policy_name = "mycompany-organization-terraform-states"
  trusted_group_names = [
    "${aws_iam_group.mycompany_internal_admins.name}"
  ]
  trusted_role_names = []
  require_mfa        = false
  input_tags         = local.common_tags
}
```

## Example config without trusting any other accounts
In this case, you just don't specific other accounts. Then, you use the default kms key along with the dynamodb table.

```hcl
module "terraform_state" {
  source  = "StratusGrid/terraform-state-s3-bucket-centralized-with-roles/aws"
  version = "~> 4.1"

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
```

---

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.account_state_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.account_state_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.account_state_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.specific_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.specific_remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.remote_state_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_arns"></a> [account\_arns](#input\_account\_arns) | Arns for accounts / roles in accounts which are given a role they are able to assume to access their state. | `list(string)` | `[]` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Blocks public ACLs on the bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_global_account_arns"></a> [global\_account\_arns](#input\_global\_account\_arns) | Arns for a account(s) / roles in account(s) that would be allowed access to all account states, for instance a global users account. Restrictions of which of that accounts users were able to access a given state would need to be further restricted inside of the global account(s) themselves. | `list(string)` | `[]` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. Causes Amazon S3 to ignore public ACLs on this bucket and any objects that it contains. | `bool` | `true` | no |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_log_bucket_id"></a> [log\_bucket\_id](#input\_log\_bucket\_id) | ID of logging bucket to be targeted for S3 bucket logs | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to use as prefix on object names | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | bucket friendly name |
| <a name="output_dynamodb_table"></a> [dynamodb\_table](#output\_dynamodb\_table) | dynamodb friendly name |
| <a name="output_iam_role_arns"></a> [iam\_role\_arns](#output\_iam\_role\_arns) | arns for each IAM role that can be assumend for the corresponding account's terraform state |
| <a name="output_kms_default_key_alias_arn"></a> [kms\_default\_key\_alias\_arn](#output\_kms\_default\_key\_alias\_arn) | kms key arn that is created by default. Use this when just using this for a state bucket and not from other accounts. |
| <a name="output_kms_default_key_arn"></a> [kms\_default\_key\_arn](#output\_kms\_default\_key\_arn) | kms key alias arn that is created by default. Use this when just using this for a state bucket and not from other accounts. |
| <a name="output_kms_key_alias_arns"></a> [kms\_key\_alias\_arns](#output\_kms\_key\_alias\_arns) | kms key alias arns for each specific account |
| <a name="output_kms_key_arns"></a> [kms\_key\_arns](#output\_kms\_key\_arns) | kms key arns for each specific account |

---

## Contributors
- Chris Hurst [GenesisChris](https://github.com/GenesisChris)
- Ivan Casco [ivancasco-sg](https://github.com/ivancasco-sg)
- Jason Drouhard [jason-drouhard](https://github.com/jason-drouhard)
- Matt Barlow [mattbarlow-sg](https://github.com/mattbarlow-sg)
- Chris Childress [chrischildresssg](https://github.com/chrischildresssg)

<span style="color:red">Note:</span> Manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml .`
<!-- END_TF_DOCS -->