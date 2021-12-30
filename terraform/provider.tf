provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.env
      manage_by   = var.managed_by
      version     = var.site_version
    }
  }
}
