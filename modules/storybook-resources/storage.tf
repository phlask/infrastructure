resource "aws_s3_bucket" "storybook_site" {
  bucket = var.env_name == "prod" ? "storybook.phlask.me" : "${var.env_name}.storybook.${var.common_domain}"
}

resource "aws_s3_bucket_policy" "storybook_site_bucket_policy" {
  bucket = aws_s3_bucket.storybook_site.id
  policy = data.aws_iam_policy_document.storybook_site_iam_policy.json
}

data "aws_iam_policy_document" "storybook_site_iam_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.storybook_site.arn}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.storybook_site.arn]
    }
  }
}
