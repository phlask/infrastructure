resource "aws_cloudfront_origin_access_control" "storybook_site" {
  name                              = "storybook_site_${var.env_name}"
  description                       = "S3 Bucket Access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "storybook_site" {
  origin {
    domain_name              = aws_s3_bucket.storybook_site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.storybook_site.id
    origin_id                = local.website_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100" # US & Europe Only
  default_root_object = "index.html"

  aliases = ["${var.env_name}.storybook.${var.common_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_origin_id

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    compress = true

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.storybook_site.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}
