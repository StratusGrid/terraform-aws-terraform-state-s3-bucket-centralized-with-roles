locals {
  account_from_arn = "/^([^:]*)+:([^:]*)+:([^:]*)+:([^:]*)+:([^:]*)+:([^/]*)+(/([^/]*))?$/"
}

resource "aws_kms_key" "specific_remote_state_backend" {
  count               = length(var.account_arns)
  description         = "Key for ${replace(var.account_arns[count.index], local.account_from_arn, "$5")} remote state backend"
  enable_key_rotation = true
  tags                = var.input_tags
}

resource "aws_kms_alias" "specific_state_backend" {
  count         = length(var.account_arns)
  name          = "alias/${var.name_prefix}-remote-state-backend-${replace(var.account_arns[count.index], local.account_from_arn, "$5")}${var.name_suffix}"
  target_key_id = aws_kms_key.specific_remote_state_backend.*.key_id[count.index]
}

data "aws_iam_policy_document" "account_specific_policy" {
  count = length(var.account_arns)
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      aws_s3_bucket.remote_state_backend.arn
    ]
    sid = "AllowAccessToRemoteStateBackendBucket"
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      "${aws_s3_bucket.remote_state_backend.arn}/${replace(var.account_arns[count.index], local.account_from_arn, "$5")}",
      "${aws_s3_bucket.remote_state_backend.arn}/${replace(var.account_arns[count.index], local.account_from_arn, "$5")}/*"
    ]
    sid = "AllowAccessToRemoteStateBackendKey"
  }
  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = [
      aws_kms_key.specific_remote_state_backend.*.arn[count.index]
    ]
    sid = "AllowUseOfRemoteStateBackendKMSKey"
  }
  statement {
    actions = [
      "dynamodb:Batch*",
      "dynamodb:DeleteItem",
      "dynamodb:Describe*",
      "dynamodb:Get*",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.remote_state_backend.arn
    ]
    sid = "AllowAccessToLockTable"
  }
}

resource "aws_iam_policy" "account_state_policy" {
  count       = length(var.account_arns)
  name        = "${replace(var.account_arns[count.index], local.account_from_arn, "$5")}-terraform-state-assumed-policy"
  description = "Policy given upon role assumption of ${replace(var.account_arns[count.index], local.account_from_arn, "$5")}-terraform-state role"
  policy      = data.aws_iam_policy_document.account_specific_policy.*.json[count.index]
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = length(var.account_arns)

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = flatten([var.account_arns[count.index], var.global_account_arns])
    }

    actions = ["sts:AssumeRole"]

  }
}

resource "aws_iam_role" "account_state_role" {
  count              = length(var.account_arns)
  name               = "${replace(var.account_arns[count.index], local.account_from_arn, "$5")}-terraform-state"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.*.json[count.index]
}

resource "aws_iam_role_policy_attachment" "account_state_role" {
  count      = length(var.account_arns)
  role       = aws_iam_role.account_state_role.*.name[count.index]
  policy_arn = aws_iam_policy.account_state_policy.*.arn[count.index]
}
