resource "aws_iam_role" "test_page_redirect" {
  name = "test-page-redirect"
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

resource "aws_iam_role_policy_attachment" "test_page_redirect" {
  role       = aws_iam_role.test_page_redirect.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

data "archive_file" "test_page_redirect" {
  type             = "zip"
  source_dir       = "${path.module}/src_code/test-page-redirect"
  output_file_mode = "0666"
  output_path      = "${path.module}/local_output/test-page-redirect.zip"
}

resource "aws_lambda_function" "test_page_redirect" {
  provider = aws.us-east-1

  filename      = data.archive_file.test_page_redirect.output_path
  function_name = "test-page-redirect"
  role          = aws_iam_role.test_page_redirect.arn
  handler       = "lambda_function.lambda_handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.test_page_redirect.output_path)

  runtime = "python3.12"

  tags = {
    Terraform = true
  }
}
