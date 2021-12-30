variable "domain" {
  type        = string
  description = "domains name which need a certification"
}

variable "site_version" {
  type        = string
  description = "version number of the infrastructure code"
}

variable "sans" {
  type        = list(string)
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
