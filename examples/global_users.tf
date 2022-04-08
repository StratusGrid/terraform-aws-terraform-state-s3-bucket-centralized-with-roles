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

