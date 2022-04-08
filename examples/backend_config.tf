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

