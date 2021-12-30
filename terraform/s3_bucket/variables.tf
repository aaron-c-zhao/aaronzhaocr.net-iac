variable "s3_buckets" {
  type = map(object({
    bucket_name                   = string
    allowed_principal_type        = string
    allowed_principal_identifiers = list(string)
  }))
}
