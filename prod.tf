module "prod_site" {
  source = "./modules/phlask-baseline-resources"

  env_name = "prod"
  default_cache_behavior = {
    default_ttl = 300
    max_ttl     = 600

    function_association = [
      {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.www_redirect.arn
      }
    ]
  }
  ordered_cache_behavior = [
    {
      path_pattern    = "submit-image"
      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

      lambda_function_association = [
        {
          event_type   = "viewer-request"
          include_body = false
          lambda_arn   = aws_lambda_function.image_submission_handler.qualified_arn
        }
      ]
    },
    {
        path_pattern               = "/images/*"
        allowed_methods            = ["GET","HEAD"]
        cached_methods             = ["GET","HEAD"]
        cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
        target_origin_id           = local.images_origin_id

        function_association = [
          {
            event_type   = "viewer-request"
            function_arn = aws_cloudfront_function.image-path-cleanup.arn
          }
        ]
      }
  ]

  common_domain      = var.common_domain
  additional_aliases = ["www.${var.common_domain}"]

  origin_access_control_id_images = aws_cloudfront_origin_access_control.images.id

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}

resource "aws_cloudfront_function" "www_redirect" {
  name    = "www-redirect"
  comment = "Managed by Terraform"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/src_code/www-redirect/function.js")
}
