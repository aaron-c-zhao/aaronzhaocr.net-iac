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


# create s3 bucket which will host the static site
resource "aws_s3_bucket" "site_host_bucket" {
  bucket = "www.aaronzhaocr.net"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "hello/"
    },
    "Redirect": {
        "ReplacekeyPrefixWith": "helloworld/"
    }
}]
EOF
  }
}

# TODO: restric access
# bucket policy: allow all principals to get object from bucket
# even though this is a iam_policy it can still be used as a bucket policy
# as long as principals presents in the policy
data "aws_iam_policy_document" "allow_public_access_to_bucket" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.site_host_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.site_host_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access_to_bucket.json
}

