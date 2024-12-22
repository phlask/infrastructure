data "aws_s3_bucket" "phlask_images" {
  bucket = var.phlask_images_bucket_name
}

data "aws_s3_bucket" "phlask_logs" {
  bucket = var.phlask_logs_bucket_name
}

resource "aws_s3_bucket" "phlask_site" {
  bucket = var.env_name == "prod" ? "phlask.me" : "${var.env_name}.${var.common_domain}"
}

resource "aws_s3_bucket_website_configuration" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id
  policy = data.aws_iam_policy_document.phlask_site.json
}

data "aws_iam_policy_document" "phlask_site" {
  statement {
    sid = "PublicReadGetObject"

    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.phlask_site.arn}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:Referer"
      values   = ["https://${var.env_name == "prod" ? "phlask.me" : "${var.env_name}.${var.common_domain}"}/*"]
    }
  }
}

resource "aws_s3_bucket_acl" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "phlask_site" {
  bucket = aws_s3_bucket.phlask_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}