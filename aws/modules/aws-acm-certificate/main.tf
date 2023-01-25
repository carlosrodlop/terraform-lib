data "aws_route53_zone" "domain_name" {
  name = var.domain_name
}

resource "aws_acm_certificate" "this" {
  domain_name       = length(var.subdomain) > 0 ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
#https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.domain_name.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}
