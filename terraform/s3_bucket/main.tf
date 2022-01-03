# create s3 bucket which will host the static site
resource "aws_s3_bucket" "site_host_bucket" {
  for_each = var.s3_buckets
  bucket   = each.value.bucket_name
  acl      = "public-read"

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


data "aws_cloudformation_export" "role_arn" {
  name = var.github_actions_execution_role_arn
}


# bucket policy: allow all principals to get object from bucket
# even though this is a iam_policy it can still be used as a bucket policy
# as long as principals presents in the policy
data "aws_iam_policy_document" "allow_public_access_to_bucket" {
  for_each = aws_s3_bucket.site_host_bucket
  statement {
    principals {
      type        = var.s3_buckets[each.key].allowed_principal_type
      identifiers = var.s3_buckets[each.key].allowed_principal_identifiers
    }

    actions = ["s3:GetObject"]

    resources = ["${each.value.arn}/*"]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_cloudformation_export.role_arn.value]
    }

    actions = ["s3:PutObject", "s3:DeleteObject"]

    resources = ["${each.value.arn}/*"]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_cloudformation_export.role_arn.value]
    }

    actions = ["s3:ListBucket"]

    resources = ["${each.value.arn}"]
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  for_each = aws_s3_bucket.site_host_bucket
  bucket   = each.value.id
  policy   = data.aws_iam_policy_document.allow_public_access_to_bucket[each.key].json
}

