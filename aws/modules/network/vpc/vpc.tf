# ******************************************************************************
# Create VPC, IGW, NAT GW
# ******************************************************************************

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block

    tags = merge(
        {Name = var.name},
        var.tags
    )
}

resource "aws_internet_gateway" "igw" {
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
