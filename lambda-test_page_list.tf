resource "aws_iam_role" "test_page_list" {
  name = "test-page-list"
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

resource "aws_iam_role_policy_attachment" "test_page_list" {
  role       = aws_iam_role.test_page_list.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy" "test_page_list" {
  name = "test-bucket-access"
  role = aws_iam_role.test_page_list.id

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
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::test.${var.common_domain}/*",
          "arn:aws:s3:::test.${var.common_domain}"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "test_page_list_dynamodb_access" {
  name = "DynamoDBAccess"
  path = "/"
  #   description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:ListTables"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/test-page-list/index/*",
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/test-page-list"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test_page_list_dynamodb_access" {
  role       = aws_iam_role.test_page_list.name
  policy_arn = aws_iam_policy.test_page_list_dynamodb_access.arn
}

data "archive_file" "test_page_list" {
  type             = "zip"
  source_dir       = "${path.module}/src_code/test-page-list"
  output_file_mode = "0666"
  output_path      = "${path.module}/local_output/test-page-list.zip"
}

resource "aws_lambda_function" "test_page_list" {
  provider = aws.us-east-1

  filename      = data.archive_file.test_page_list.output_path
  function_name = "test-page-list"
  role          = aws_iam_role.test_page_list.arn
  handler       = "lambda_function.lambda_handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.test_page_list.output_path)

  runtime = "python3.7"

  timeout = 5

  tags = {
    Terraform = true
  }
}

resource "aws_dynamodb_table" "test_page_list" {
  provider = aws.us-east-1

  name           = "test-page-list"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "gitHash"

  attribute {
    name = "gitHash"
    type = "S"
  }

  ttl {
    attribute_name = "expirationTime"
    enabled        = true
  }

  tags = {
    Terraform = true
  }
}
