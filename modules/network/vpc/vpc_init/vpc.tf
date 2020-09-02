locals {
  public_vpc     = var.public_subnets != {} ? { (var.cidr_block) = data.aws_region.current.name } : {}
  public_subnets = var.nat_gw ? var.public_subnets : {}
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

# Create VPC (https://www.terraform.io/docs/providers/aws/r/vpc.html)
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      "Name" = "${var.use_case}-${var.segment}-${data.aws_region.current.name}",
    },
    var.tags
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  for_each = var.secondary_cidr_blocks

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------

# Private subnets
resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  # availability_zone_id    = each.value
  cidr_block = each.key

  tags = merge(
    {
      "Name"    = "${var.use_case}-${var.segment}-${each.value}-private-subnet",
      "network" = "private"
    },
    var.tags
  )
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value
  map_public_ip_on_launch = var.map_public_ip_on_launch
  # availability_zone_id    = each.value
  cidr_block = each.key

  tags = merge(
    {
      "Name"    = "${var.use_case}-${var.segment}-${each.value}-public-subnet",
      "network" = "public"
    },
    var.tags
  )
}

# Internal subnets
resource "aws_subnet" "internal_subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  for_each   = var.internal_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  # availability_zone_id    = each.value
  cidr_block = each.key

  tags = merge(
    {
      "Name"    = "${var.use_case}-${var.segment}-${each.value}-internal-subnet",
      "network" = "internal"
    },
    var.tags
  )
}

# ------------------------------------------------------------------------------
# IGW
# ------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  for_each = local.public_vpc

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.use_case}-${var.segment}-igw"
    },
    var.tags
  )
}

# ------------------------------------------------------------------------------
# NAT GW
# ------------------------------------------------------------------------------

resource "aws_eip" "nat_gw_eip" {
  for_each = local.public_subnets
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = local.public_subnets

  depends_on = [aws_internet_gateway.igw[0]]

  allocation_id = aws_eip.nat_gw_eip[each.key].id

  subnet_id = aws_subnet.public_subnet[each.key].id
}

# ------------------------------------------------------------------------------
# Handle Defaults
# ------------------------------------------------------------------------------

# Default Network ACL (https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)

# When Terraform first adopts the Default Network ACL, it immediately removes all rules in 
# the ACL. It then proceeds to create any rules specified in the configuration. This step 
# is required so that only the rules specified in the configuration are created.

# This resource treats its inline rules as absolute; only the rules defined inline are 
# created, and any additions/removals external to this resource will result in diffs being 
# shown. For these reasons, this resource is incompatible with the aws_network_acl_rule resource.

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  tags = merge(
    {
      "Name" = "${var.use_case}-${var.segment}-default-nacl"
    },
    var.tags
  )
}

# Default Security Group

# When Terraform first adopts the Default Security Group, it immediately removes all ingress and egress rules 
# in the Security Group. It then proceeds to create any rules specified in the configuration. This step is 
# required so that only the rules specified in the configuration are created.

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = "${var.use_case}-${var.segment}-default-sg"
    },
    var.tags
  )

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}