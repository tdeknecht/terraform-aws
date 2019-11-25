# ******************************************************************************
# Create VPC, IGW, NAT GW
# ******************************************************************************

locals {
    is_public = var.public_subnets != {} ? true : false
    #is_public = var.public_subnets != {} ? {"region_" = "vpcname_"} : {}

}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block

    tags = merge(
        {Name = var.name},
        var.tags
    )
}

resource "aws_internet_gateway" "igw" {
    count = local.is_public ? 1 : 0
    #for_each = local.is_public

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-igw"},
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
