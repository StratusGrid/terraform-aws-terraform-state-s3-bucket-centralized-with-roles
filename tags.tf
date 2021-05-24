locals {
  common_tags = merge(var.input_tags, {
    "ModuleSourceRepo" = "github.com/StratusGrid/terraform-aws-terraform-state-s3-bucket-centralized-with-roles"
  })
}