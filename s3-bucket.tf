locals {
  log_bucket_target_prefix = length(var.log_bucket_target_prefix) > 0 ? var.log_bucket_target_prefix : "s3/${var.name_prefix}-remote-state-backend${var.name_suffix}/"
}

resource "aws_s3_bucket" "remote_state_backend" {
  bucket = "${var.name_prefix}-remote-state-backend${var.name_suffix}"
  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_logging" "remote_state_backend" {
  bucket = aws_s3_bucket.remote_state_backend.id

  target_bucket = var.log_bucket_id
  target_prefix = local.log_bucket_target_prefix
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_backend" {
  bucket = aws_s3_bucket.remote_state_backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.remote_state_backend.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "remote_state_backend" {
  bucket = aws_s3_bucket.remote_state_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "encrypted_transit_bucket_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    condition {
      test = "Bool"
      values = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.remote_state_backend.arn,
      "${aws_s3_bucket.remote_state_backend.arn}/*"
    ]
    sid = "DenyUnsecuredTransport"
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "StringNotEquals"
      values = [
        "aws:kms"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.remote_state_backend.arn,
      "${aws_s3_bucket.remote_state_backend.arn}/*"
    ]
    sid = "DenyIncorrectEncryptionHeader"
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "Null"
      values = [
        "true"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.remote_state_backend.arn,
      "${aws_s3_bucket.remote_state_backend.arn}/*"
    ]
    sid = "DenyUnencryptedObjectUploads"
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "StringNotEquals"
      values = [
        "bucket-owner-full-control"
      ]
      variable = "s3:x-amz-acl"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*"
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.remote_state_backend.arn,
      "${aws_s3_bucket.remote_state_backend.arn}/*"
    ]
    sid = "RequireBucketOwnerACL"
  }
}

resource "aws_s3_bucket_policy" "remote_state_backend" {
  bucket = aws_s3_bucket.remote_state_backend.id
  policy = data.aws_iam_policy_document.encrypted_transit_bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.remote_state_backend.bucket

  # The parameters below are set to true by default
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

