data "aws_region" "current" {}

locals {
    # Create a new map that behaves similar to the old method using count as a flag. This time it has a name, and is not a count index.
    public_vpc     = var.public_subnets != {} ? { (var.cidr_block) = data.aws_region.current.name } : {}
    public_subnets = var.nat_gw ? var.public_subnets : {}
}

# ******************************************************************************
# VPC
# ******************************************************************************

# Create VPC (https://www.terraform.io/docs/providers/aws/r/vpc.html)
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block

    tags = merge(
        { Name = var.name },
        var.tags
    )
}

# ******************************************************************************
# Subnets
# ******************************************************************************

# Private subnets
resource "aws_subnet" "private_subnet" {
    for_each                = var.private_subnets

    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = each.value
    # availability_zone_id    = each.value
    cidr_block              = each.key

    tags = merge(
        {
            Name = "${var.name}-${var.ou}-${each.value}-private-subnet",
            network = "private"
        },
        var.tags
    )
}

# Public subnets
resource "aws_subnet" "public_subnet" {
    for_each            = var.public_subnets

    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = each.value
    # availability_zone_id    = each.value
    cidr_block              = each.key

    tags = merge(
        {
            Name = "${var.name}-${var.ou}-${each.value}-public-subnet",
            network = "public"
        },
        var.tags
    )
}

# ******************************************************************************
# IGW
# ******************************************************************************

resource "aws_internet_gateway" "igw" {
    for_each = local.public_vpc

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        { Name = "${var.name}-${var.ou}-igw" },
        var.tags
    )
}

# ******************************************************************************
# NAT GW
# ******************************************************************************

resource "aws_eip" "nat_gw_eip" {
    for_each = local.public_subnets
}

resource "aws_nat_gateway" "nat_gw" {
    for_each = local.public_subnets

    depends_on = [aws_internet_gateway.igw[0]]

    allocation_id = aws_eip.nat_gw_eip[each.key].id

    subnet_id = aws_subnet.public_subnet[each.key].id
}
