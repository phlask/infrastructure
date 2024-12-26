module "test_site" {
  source = "./modules/phlask-baseline-resources"

  env_name = "test"
  custom_error_response = [
    {
      error_caching_min_ttl = 10
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]
  default_cache_behavior = {
    default_ttl = 86400
    max_ttl     = 86400

    function_association = [
        {
            event_type   = "viewer-request"
            function_arn = aws_cloudfront_function.react-url-rewrite.arn
        }
    ]

    lambda_function_association = [
      {
        event_type   = "origin-response"
        include_body = false
        lambda_arn   = aws_lambda_function.test_page_redirect.qualified_arn
      }
    ]
  }
  ordered_cache_behavior = [
    {
      path_pattern    = "/"
      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      forwarded_values = [
        {
          headers = []

          cookies = {
            forward = "none"
          }
        }
      ]

      lambda_function_association = [
        {
          event_type   = "viewer-request"
          include_body = false
          lambda_arn   = aws_lambda_function.test_page_list.qualified_arn
        }
      ]
    },
    {
      path_pattern    = "testResults/*"
      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      forwarded_values = [
        {
          headers = []

          cookies = {
            forward = "none"
          }
        }
      ]

      lambda_function_association = [
        {
          event_type   = "viewer-request"
          include_body = false
          lambda_arn   = aws_lambda_function.test_results_display.qualified_arn
        }
      ]
    },
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
      path_pattern    = "tap-images/*"
      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.s3_origin.id

      target_origin_id = local.images_origin_id
    }
  ]

  common_domain = var.common_domain
  
  origin_access_control_id_images = aws_cloudfront_origin_access_control.images.id

  phlask_images_bucket_name = aws_s3_bucket.images.id
  phlask_logs_bucket_name   = aws_s3_bucket.logs.id

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
