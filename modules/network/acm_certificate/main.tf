# ------------------------------------------------------------------------------
# Data and Locals
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_account_alias" "current" {}

# ------------------------------------------------------------------------------
# ACM
# ------------------------------------------------------------------------------

resource "aws_acm_certificate" "cert" {
  domain_name = var.certificate_domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  tags                      = merge(
    var.tags,
    {
      "Name" = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-${var.certificate_domain_name}",
    }
  )

  # import cert
  private_key       = var.private_key
  certificate_body  = var.certificate_body
  certificate_chain = var.certificate_chain

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Route 53
# ------------------------------------------------------------------------------

data "aws_route53_zone" "zone" {
  count = var.validation_domain_name != null ? 1 : 0

  name         = var.validation_domain_name
  private_zone = false
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.zone[0].zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}