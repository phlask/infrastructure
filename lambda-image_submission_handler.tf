resource "aws_iam_role" "image_submission_handler" {
  name = "image-submission-handler"
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

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  path_prefix = "/service-role/"
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "image_submission_handler" {
  role       = aws_iam_role.image_submission_handler.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy" "image_submission_handler" {
  name = "bucket_access"
  role = aws_iam_role.image_submission_handler.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:ListMultipartUploadParts",
        ]
        Effect   = "Allow"
        Resource = [
            aws_s3_bucket.images.arn,
            "${aws_s3_bucket.images.arn}/*"
        ]
      },
    ]
  })
}

data "archive_file" "image_submission_handler" {
  type             = "zip"
  source_dir       = "${path.module}/src_code/image-submission-handler"
  output_file_mode = "0666"
  output_path      = "${path.module}/local_output/image-submission-handler.zip"
}

resource "aws_lambda_function" "image_submission_handler" {
  provider = aws.us-east-1

  filename      = data.archive_file.image_submission_handler.output_path
  function_name = "image-submission-handler"
  role          = aws_iam_role.image_submission_handler.arn
  handler       = "index.handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.image_submission_handler.output_path)

  runtime = "nodejs12.x"

  tags = {
      Terraform = true
  }
}
