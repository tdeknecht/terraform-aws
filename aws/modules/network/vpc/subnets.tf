# ******************************************************************************
# Create subnets
# ******************************************************************************

# Private subnets
resource "aws_subnet" "private_subnet" {
    for_each            = var.private_subnets

    vpc_id              = aws_vpc.vpc.id
    availability_zone   = each.value
    cidr_block          = each.key

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

    vpc_id              = aws_vpc.vpc.id
    availability_zone   = each.value
    cidr_block          = each.key

    tags = merge(
        {
            Name = "${var.name}-${var.ou}-${each.value}-public-subnet",
            network = "public"
        },
        var.tags
    )
}
