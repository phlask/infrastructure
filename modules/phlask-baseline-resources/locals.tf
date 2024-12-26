locals {
  website_bucket_origin_id = "S3-${aws_s3_bucket.phlask_site.id}"
  images_origin_id         = "S3-${data.aws_s3_bucket.phlask_images.id}"
}