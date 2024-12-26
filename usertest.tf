# Purpose: Run moderated tests
# URL: usertest.phlask.me
# Firebase Name: phlask-usertest
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "usertest_site" {
  source = "./modules/phlask-baseline-resources"

  env_name = "usertest"
  default_cache_behavior = {
    default_ttl = 300
    max_ttl     = 600

    function_association = [
        {
            event_type   = "viewer-request"
            function_arn = aws_cloudfront_function.react-url-rewrite.arn
        }
    ]
  }
  ordered_cache_behavior = [
    {
      path_pattern    = "reset-data"
      allowed_methods = ["GET", "HEAD"]
      cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id

      lambda_function_association = [
        {
          event_type   = "viewer-request"
          include_body = false
          lambda_arn   = aws_lambda_function.usertest_data_reset.qualified_arn
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

  common_domain = var.common_domain

  origin_access_control_id_images = aws_cloudfront_origin_access_control.images.id

  phlask_images_bucket_name = aws_s3_bucket.images.id
  phlask_logs_bucket_name   = aws_s3_bucket.logs.id

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}

# Mechanism to reset the usertest site DB between tests
# lambda function
# extra behavior to invoke the function, no caching
resource "aws_iam_role" "usertest_data_reset" {
  name = "usertest-data-reset"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "usertest_data_reset" {
  role       = aws_iam_role.usertest_data_reset.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy" "usertest_data_reset" {
  name = "parameter_access"
  role = aws_iam_role.usertest_data_reset.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:key/5a1de7cb-a906-45ae-bf2f-e8a105ccae19"
      },
      {
        Action = [
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/firebase/sdk-credentials"
      }
    ]
  })
}

data "archive_file" "usertest_data_reset" {
  type             = "zip"
  source_dir       = "${path.module}/src_code/usertest-data-reset"
  output_file_mode = "0666"
  output_path      = "${path.module}/local_output/usertest-data-reset.zip"
}

resource "aws_lambda_function" "usertest_data_reset" {
  provider = aws.us-east-1

  filename      = data.archive_file.usertest_data_reset.output_path
  function_name = "usertest-data-reset"
  role          = aws_iam_role.usertest_data_reset.arn
  handler       = "lambda_function.lambda_handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.usertest_data_reset.output_path)

  runtime = "python3.12"

  timeout = 5

  tags = {
    Terraform = true
  }
}
