# ------------------------------------------------------------------------------
# Route 53 Zone
# ------------------------------------------------------------------------------

resource "aws_route53_zone" "zone" {
  name          = var.name
  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = var.tags

  dynamic "vpc" {
    for_each = var.vpc_init

    content {
      vpc_id     = vpc.key
      vpc_region = vpc.value
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_zone_association" "secondary" {
  for_each = var.vpc_secondary

  zone_id    = aws_route53_zone.zone.zone_id
  vpc_id     = each.key
  vpc_region = each.value
}