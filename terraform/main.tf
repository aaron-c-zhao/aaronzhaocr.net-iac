# secure all the domains
resource "aws_acm_certificate" "site_domains" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = var.sans

  tags = {
    Name = "domain_certification"
  }

  lifecycle {
    create_before_destroy = true
  }
}


module "s3_bucket" {
  source = "./s3_bucket"

  s3_buckets = {
    "prod_bucket" = {
      bucket_name                   = var.bucket_names["prod_bucket"]
      allowed_principal_type        = "*"
      allowed_principal_identifiers = ["*"]
    }
    "stage_bucket" = {
      bucket_name                   = var.bucket_names["stage_bucket"]
      allowed_principal_type        = "*"
      allowed_principal_identifiers = ["*"]
    }
  }

}
