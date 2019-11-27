# ******************************************************************************
# Create VPC, IGW, NAT GW
# ******************************************************************************

data "aws_region" "current" {}

locals {
    # Create a new map that behaves similar to the old method using count as a flag. This time it has a name, and is not a count index.
    is_public = var.public_subnets != {} ? { (var.cidr_block) = data.aws_region.current.name } : {}
}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block

    tags = merge(
        {Name = var.name},
        var.tags
    )
}

resource "aws_internet_gateway" "igw" {
    for_each = local.is_public

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-${var.ou}-igw"},
        var.tags
    )
}

resource "aws_eip" "nat_gw_eip" {
    for_each = var.public_subnets
}

resource "aws_nat_gateway" "nat_gw" {
    for_each = var.public_subnets

    depends_on = [aws_internet_gateway.igw[0]]

    allocation_id = aws_eip.nat_gw_eip[each.key].id

    subnet_id = aws_subnet.public_subnet[each.key].id
}
