# secure all the domains
resource "aws_acm_certificate" "site_domains" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = [for k, v in var.sans : v]

  tags = {
    Name = "domain_certification"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# setup s3 buckets for staging and production
module "s3_bucket" {
  source = "./s3_bucket"

  s3_buckets = {
    "prod_bucket" = {
      bucket_name                   = var.bucket_names["prod_bucket"]
      allowed_principal_type        = "AWS"
      allowed_principal_identifiers = [aws_cloudfront_origin_access_identity.s3_oai.iam_arn]
    }
    "stage_bucket" = {
      bucket_name                   = var.bucket_names["stage_bucket"]
      allowed_principal_type        = "*"
      allowed_principal_identifiers = ["*"]
    }
  }
}


# set up cloudfront distribution
locals {
  s3_origin_id = "prod_site_origin"
}

resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "Identity for accessing S3 bucket which hosts the production site"
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.s3_bucket.buckets["prod_bucket"].bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for the site"
  default_root_object = "index.html"

  # TODO: include log config
  /*
    logging_config {
        include_cookies = false
        bucket = ""
        prefix = ""
    }
  */

  aliases = [var.sans["blog_domain"], var.domain]

  default_cache_behavior {
    # all methods will be processed by cloudfront
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "NL"]
    }
  }
  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = aws_acm_certificate.site_domains.arn
  }
}

# create DNS records which points custom domains to cloudfront
data "aws_route53_zone" "site_zone" {
  name = var.domain
}

resource "aws_route53_record" "prod_site_records" {
  for_each = {
    main_domain = var.domain
    prod_domain = var.sans["prod_domain"]
    blog_domain = var.sans["blog_domain"]
  }
  zone_id = data.aws_route53_zone.site_zone.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
