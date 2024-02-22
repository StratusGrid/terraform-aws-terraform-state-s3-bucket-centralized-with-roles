variable "name_prefix" {
  description = "String to use as prefix on object names"
  type        = string
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using"
  type        = string
  default     = ""
}

variable "log_bucket_id" {
  description = "ID of logging bucket to be targeted for S3 bucket logs"
  type        = string
}

variable "log_bucket_target_object_key_format" {
  description = "Map containing logging bucket target object key format configuration."
  type        = any
  default     = {}
}

variable "log_bucket_target_prefix" {
  description = "The prefix for all log object keys. Define this varible to override the default."
  type        = string
  default     = ""
}

variable "account_arns" {
  description = "Arns for accounts / roles in accounts which are given a role they are able to assume to access their state."
  type        = list(string)
  default     = []
}

variable "global_account_arns" {
  description = "Arns for a account(s) / roles in account(s) that would be allowed access to all account states, for instance a global users account. Restrictions of which of that accounts users were able to access a given state would need to be further restricted inside of the global account(s) themselves."
  type        = list(string)
  default     = []
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  description = "Blocks public ACLs on the bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket. Causes Amazon S3 to ignore public ACLs on this bucket and any objects that it contains."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked."
  type        = bool
  default     = true
}

variable "dynamodb_table_billing_type" {
  description = "Defines whether the DynamoDB table used for state locking and consistency checking should use on-demand or provisioned capacity mode."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.dynamodb_table_billing_type == "PAY_PER_REQUEST" || var.dynamodb_table_billing_type == "PROVISIONED"
    error_message = "The dynamodb_table_billing_type value must be one of two valid options: PAY_PER_REQUEST or PROVISIONED. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#billing_mode for more information."
  }
}

variable "dynamodb_table_read_capacity" {
  description = "Defines the number of read units for the state locking and consistency table. If the dynamodb_table_billing_type is PROVISIONED, this field is required."
  type        = number
  default     = 0
}

variable "dynamodb_table_write_capacity" {
  description = "Defines the number of write units for the state locking and consistency table. If the dynamodb_table_billing_type is PROVISIONED, this field is required."
  type        = number
  default     = 0
}

variable "enable_encryption" {
  description = "Allows disable the the bucket encryption configuration"
  type        = bool
  default     = true
}