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
/*
resource "aws_subnet" "subnet" {
    for_each = var.subnets

    vpc_id = aws_vpc.vpc.id
    availability_zone   = each.value[0]
    cidr_block          = each.value[1]

    tags = merge(
        {Name = "${var.name}-${each.value[0]}-${each.key}-subnet"},
        var.tags
    )
}
*/
/*
subnets = {"private" = {"us-east-1a" = "10.0.5.0/24", "us-east-1b" = "10.0.6.0/24"}

key = "private"
value = {"us-east-1a" = "10.0.5.0/24", "us-east-1b" = "10.0.6.0/24"}
*/
