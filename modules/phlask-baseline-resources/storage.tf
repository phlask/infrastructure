data "aws_s3_bucket" "phlask_images" {
  bucket = var.phlask_images_bucket_name
}

data "aws_s3_bucket" "phlask_logs" {
  bucket = var.phlask_logs_bucket_name
}

resource "aws_s3_bucket" "phlask_site" {
  bucket = var.env_name == "prod" ? "phlask.me" : "${var.env_name}.${var.common_domain}"
}

resource "aws_s3_bucket_policy" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id
  policy = data.aws_iam_policy_document.phlask_site.json
}

data "aws_iam_policy_document" "phlask_site" {
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
      "${aws_s3_bucket.phlask_site.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.phlask_site.arn]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}