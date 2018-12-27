variable "name_prefix" {
  description = "String to use as prefix on object names"
  type = "string"
}

variable "log_bucket_id" {
  description = "ID of logging bucket to be targeted for S3 bucket logs"
  type = "string"
}

variable "account_arns" {
  description = "Arns for accounts / roles in accounts which are given a role they are able to assume to access their state."
  type = "list"
  default = []
}

variable "global_account_arns" {
  description = "Arns for a account(s) / roles in account(s) that would be allowed access to all account states, for instance a global users account. Restrictions of which of that accounts users were able to access a given state would need to be further restricted inside of the global account(s) themselves."
  type = "list"
  default = []
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type = "map"
  default = {}
}