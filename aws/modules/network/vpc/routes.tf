# ******************************************************************************
# Create route tables
# ******************************************************************************

# The VPC Default route table will be used as the private_rt and is declared as Main
resource "aws_default_route_table" "default_rt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    tags = merge(
        {Name = "${var.name}-${var.ou}-default-rt"},
        var.tags
    )
}

resource "aws_route_table" "private_rt" {
    for_each = var.private_subnets

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-${var.ou}-${each.value}-private-rt"},
        var.tags
    )
}

resource "aws_route_table" "public_rt" {
    for_each = local.is_public

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-${var.ou}-public-rt"},
        var.tags
    )
}

# ******************************************************************************
# Create routes
# ******************************************************************************

cidr_blocks = [
  for num in var.subnet_numbers:
  cidrsubnet(data.aws_vpc.example.cidr_block, 8, num)
]

# Create routes for private route tables
# Create route for NAT Gateways in each public subnet
resource "aws_route" "route_to_natgw" {
    for_each = var.public_subnets

    #route_table_id         = aws_route_table.private_rt[each.key].id
    route_table_id = [
        for subnet, az in var.private_subnets:

    ]
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
}
/*
# Create routes for public route table
# Create routes for public route tables to igw
resource "aws_route" "route_to_igw" {
    count = var.public_subnets != {} ? 1 : 0
    #for_each = local.is_public

    route_table_id          = aws_route_table.public_rt.*.id[0]
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw.*.id[0]
} */
# ******************************************************************************
# Associate subnets with route tables
# ******************************************************************************

# Associate private subnet with private route table
resource "aws_route_table_association" "private_rt_assoc" {
    for_each        = aws_subnet.private_subnet

    subnet_id       = aws_subnet.private_subnet[each.key].id
    route_table_id  = aws_route_table.private_rt[each.key].id
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_rt_assoc" {
    for_each        = aws_subnet.public_subnet

    subnet_id       = aws_subnet.public_subnet[each.key].id
    route_table_id  = aws_route_table.public_rt[data.aws_region.current.name].id
}
