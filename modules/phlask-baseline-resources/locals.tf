locals {
  website_origin_id = "S3-Website-${aws_s3_bucket_website_configuration.phlask_site.website_endpoint}"
  images_origin_id  = "S3-${data.aws_s3_bucket.phlask_images.id}"
}