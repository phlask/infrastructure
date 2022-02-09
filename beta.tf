resource "aws_s3_bucket" "beta_site" {
  provider = aws.us-east-2
  bucket = "beta.phlask.me"
  acl    = "public-read"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::beta.phlask.me/*",
            "Condition":{
                "StringLike":{"aws:Referer":["https://beta.phlask.me/*"]}
            }
        }
    ]
}
  POLICY

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "beta_site" {
  provider = aws.us-east-2
  bucket = aws_s3_bucket.test_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_acm_certificate" "test_site" {
  domain_name       = "test.phlask.me"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  test_origin_id = "S3-Website-test.phlask.me.s3-website.us-east-2.amazonaws.com"
  images_origin_id = "S3-phlask-tap-images/test"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3_origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_distribution" "test_site" {
  origin {
    origin_id = local.test_origin_id
    domain_name = aws_s3_bucket.test_site.website_endpoint

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy = "http-only"
      origin_read_timeout = 30
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.images.bucket_domain_name
    origin_id   = local.images_origin_id
    origin_path = "/test"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.images.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100" # US & Europe Only

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.test_site.bucket_domain_name
    prefix          = "testlogs/"
  }

  aliases = ["test.phlask.me"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.test_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress = true

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = "arn:aws:lambda:us-east-1:710438357722:function:test-page-redirect:2"
    }
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.test_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "arn:aws:lambda:us-east-1:710438357722:function:test-page-list:14"
    }
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "testResults/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.test_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "arn:aws:lambda:us-east-1:710438357722:function:test-results-display:4"
    }
  }

  # Cache behavior with precedence 2
  ordered_cache_behavior {
    path_pattern     = "submit-image"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.test_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = false
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "arn:aws:lambda:us-east-1:710438357722:function:image-submission-handler:11"
    }
  }

  # Cache behavior with precedence 3
  ordered_cache_behavior {
    path_pattern     = "tap-images/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.images_origin_id

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.s3_origin.id

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  # tags = {
  #   Environment = "production"
  # }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.test_site.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }
}