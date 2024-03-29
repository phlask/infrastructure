resource "aws_acm_certificate" "phlask_site" {
  provider = aws.us-east-1

  domain_name       = var.env_name == "prod" ? "phlask.me" : "${var.env_name}.${var.common_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_cloudfront_origin_access_identity" "images" {
  id = "EYLKT3B3LMJM1"
}

resource "aws_cloudfront_distribution" "phlask_site" {
  origin {
    origin_id   = local.website_origin_id
    domain_name = aws_s3_bucket_website_configuration.phlask_site.website_endpoint

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = data.aws_s3_bucket.phlask_images.bucket_domain_name
    origin_id   = local.images_origin_id
    origin_path = "/${var.env_name}"

    s3_origin_config {
      origin_access_identity = data.aws_cloudfront_origin_access_identity.images.cloudfront_access_identity_path
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl # 10
      error_code            = custom_error_response.value.error_code # 404
      response_code         = custom_error_response.value.response_code # 200
      response_page_path    = custom_error_response.value.response_page_path # "/index.html"
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # US & Europe Only

  logging_config {
    include_cookies = true
    bucket          = data.aws_s3_bucket.phlask_logs.bucket_domain_name # change to data source for a logging bucket
    prefix          = "${var.env_name}/cloudfront/"
  }

  aliases = concat(["${var.env_name == "prod" ? "phlask.me" : "${var.env_name}.${var.common_domain}"}"], var.additional_aliases)

  default_cache_behavior {
    allowed_methods  = try(var.default_cache_behavior["allowed_methods"], ["GET", "HEAD"])
    cached_methods   = try(var.default_cache_behavior["cached_methods"], ["GET", "HEAD"])
    target_origin_id = try(var.default_cache_behavior["target_origin_id"], local.website_origin_id)

    forwarded_values {
      query_string = try(var.default_cache_behavior["forwarded_values"]["query_string"], false)

      cookies {
        forward = try(var.default_cache_behavior["forwarded_values"]["cookies"]["forward"], "none")
      }
    }

    compress = true

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = try(var.default_cache_behavior["min_ttl"], 0)
    default_ttl            = try(var.default_cache_behavior["default_ttl"], 86400)
    max_ttl                = try(var.default_cache_behavior["max_ttl"], 86400)

    dynamic "lambda_function_association" {
      for_each = try(var.default_cache_behavior["lambda_function_association"], [])

      content {
        event_type = lambda_function_association.value["event_type"]
        lambda_arn = lambda_function_association.value["lambda_arn"]
      }
    }

    dynamic "function_association" {
      for_each = try(var.default_cache_behavior["function_association"], [])

      content {
        event_type   = function_association.value["event_type"]
        function_arn = function_association.value["function_arn"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior

    content {
      path_pattern             = ordered_cache_behavior.value["path_pattern"] # "/"
      allowed_methods          = try(ordered_cache_behavior.value["allowed_methods"], ["GET", "HEAD"])
      cached_methods           = try(ordered_cache_behavior.value["cached_methods"], ["GET", "HEAD"])
      target_origin_id         = try(ordered_cache_behavior.value["target_origin_id"], local.website_origin_id)
      origin_request_policy_id = try(ordered_cache_behavior.value["origin_request_policy_id"], null)

      dynamic "forwarded_values" {
        for_each = try(ordered_cache_behavior.value["forwarded_values"], [])

        content {
          query_string = try(forwarded_values.value["query_string"], false)

          cookies {
            forward = try(forwarded_values.value["cookies"]["forward"], "none")
          }
        }
      }

      cache_policy_id = try(ordered_cache_behavior.value["cache_policy_id"], null)

      min_ttl                = try(ordered_cache_behavior.value["min_ttl"], null) # 0
      default_ttl            = try(ordered_cache_behavior.value["default_ttl"], null) # 86400
      max_ttl                = try(ordered_cache_behavior.value["max_ttl"], null) # 86400
      compress               = true
      viewer_protocol_policy = "redirect-to-https"

      dynamic "lambda_function_association" {
        for_each = try(ordered_cache_behavior.value["lambda_function_association"], [])

        content {
          event_type = lambda_function_association.value["event_type"]
          lambda_arn = lambda_function_association.value["lambda_arn"]
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.env_name
    Terraform   = true
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.phlask_site.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}