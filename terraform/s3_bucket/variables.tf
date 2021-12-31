variable "s3_buckets" {
  type = map(object({
    bucket_name                   = string
    allowed_principal_type        = string
    allowed_principal_identifiers = list(string)
  }))
}

variable "github_actions_execution_role_arn" {
  type        = string
  description = "The export name of the github actions execution role arn."
}
