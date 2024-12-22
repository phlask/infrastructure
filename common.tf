data "aws_caller_identity" "current" {}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3_origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_origin_access_control" "images" {
  name                              = aws_s3_bucket.images.bucket_regional_domain_name
  description                       = "Managed by Terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_route53_zone" "phlask" {
   name = "phlask.me"
}

resource "aws_s3_bucket" "images" {
  bucket = "phlask-tap-images"
}

resource "aws_s3_bucket_acl" "images" {
  bucket = aws_s3_bucket.images.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "images" {
  bucket = aws_s3_bucket.images.id
  policy = data.aws_iam_policy_document.images.json
}

data "aws_iam_policy_document" "images" {
  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    sid = "AllowCloudFrontServicePrincipal"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/*",
    ]
    
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        module.prod_site.cf_distribution_arn,
        module.beta_site.cf_distribution_arn
      ]
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id = "clean-test-photos"

    filter {
      prefix = "test/"
    }

    status = "Enabled"

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id = "clean-beta-photos"

    filter {
      prefix = "beta/"
    }

    status = "Disabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 30
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "phlask-logs"
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_cloudfront_function" "image-path-cleanup" {
  name    = "image-path-cleanup"
  runtime = "cloudfront-js-2.0"
  comment = "Managed by Terraform"
  publish = true
  code    = file("${path.module}/src_code/image-path-cleanup/function.js")
}
