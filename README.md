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