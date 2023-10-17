data "aws_route53_zone" "primary" {
  name = "phlask.me"
}


resource "aws_route53_record" "storybook_site" {
  zone_id = data.aws_route53_zone.primary.id
  name    = "${var.env_name}.storybook.${var.common_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.storybook_site.domain_name
    zone_id                = aws_cloudfront_distribution.storybook_site.hosted_zone_id
    evaluate_target_health = true
  }
}


resource "aws_acm_certificate" "storybook_site" {
  domain_name       = "${var.env_name}.storybook.${var.common_domain}"
  validation_method = "DNS"

  tags = {
    Environment = var.env_name
  }

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_route53_record" "certificate_storybook" {
  for_each = {
    for dvo in aws_acm_certificate.storybook_site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "storybook_site" {
  certificate_arn         = aws_acm_certificate.storybook_site.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_storybook : record.fqdn]
}
