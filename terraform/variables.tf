variable "domain" {
  type        = string
  description = "domains name which need a certification"
}

variable "site_version" {
  type        = string
  description = "version number of the infrastructure code"
}

variable "sans" {
  type        = map(string)
  description = "list of subject alternative names for the site"
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "env" {
  type        = string
  description = "deployment environment type"
}

variable "managed_by" {
  type        = string
  description = "email address of the admin"
}

variable "bucket_names" {
  type        = map(string)
  description = "Name of the buckets"
}

variable "github_actions_execution_role_arn" {
  type        = string
  description = "The export name of the github actions execution role arn"
}
