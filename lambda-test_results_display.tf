data "archive_file" "test_results_display" {
  type             = "zip"
  source_dir       = "${path.module}/src_code/test-results-display"
  output_file_mode = "0666"
  output_path      = "${path.module}/local_output/test-results-display.zip"
}

resource "aws_lambda_function" "test_results_display" {
  provider = aws.us-east-1

  filename      = data.archive_file.test_results_display.output_path
  function_name = "test-results-display"
  role          = aws_iam_role.test_page_list.arn
  handler       = "lambda_function.lambda_handler"
  publish       = true

  source_code_hash = filebase64sha256(data.archive_file.test_results_display.output_path)

  runtime = "python3.12"

  tags = {
    Terraform = true
  }
}
