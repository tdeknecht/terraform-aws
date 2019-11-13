# ******************************************************************************
# Create subnets
# ******************************************************************************

resource "aws_subnet" "private_subnet" {
    for_each            = var.private_subnets

    vpc_id              = aws_vpc.vpc.id
    availability_zone   = each.key
    cidr_block          = each.value

    tags = merge(
        {Name = "${var.name}-${each.key}-private-subnet"},
        var.tags
    )
}

resource "aws_subnet" "public_subnet" {
    for_each            = var.public_subnets

    vpc_id              = aws_vpc.vpc.id
    availability_zone   = each.key
    cidr_block          = each.value

    tags = merge(
        {Name = "${var.name}-${each.key}-public-subnet"},
        var.tags
    )
}