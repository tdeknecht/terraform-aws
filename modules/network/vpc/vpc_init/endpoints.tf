# ------------------------------------------------------------------------------
# Endpoints
# ------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ssm" {
  count = var.vpc_endpoint_ssm ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    for subnet, az in var.private_subnets :
    aws_subnet.private_subnet[subnet].id
  ]
  security_group_ids  = [aws_default_security_group.default.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.vpc_endpoint_ssm ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    for subnet, az in var.private_subnets :
    aws_subnet.private_subnet[subnet].id
  ]
  security_group_ids  = [aws_default_security_group.default.id]
  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = var.vpc_endpoint_ssm ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    for subnet, az in var.private_subnets :
    aws_subnet.private_subnet[subnet].id
  ]
  security_group_ids  = [aws_default_security_group.default.id]
  private_dns_enabled = true
  tags                = var.tags
}