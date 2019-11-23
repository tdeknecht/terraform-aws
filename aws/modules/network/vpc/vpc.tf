# ******************************************************************************
# Create VPC, IGW, NAT GW
# ******************************************************************************

locals {
    is_public = var.public_subnets != {} ? true : false
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

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-igw"},
        var.tags
    )
}

/*
resource "nat_gw" {

}
*/
