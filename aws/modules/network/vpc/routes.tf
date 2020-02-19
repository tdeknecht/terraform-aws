# ******************************************************************************
# Route Tables
# ******************************************************************************

# TODO: The VPC Default route table will be used as the public_rt and is declared as Main
resource "aws_default_route_table" "default_rt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    tags = merge(
        {Name = "${var.name}-${var.ou}-default-rt"},
        var.tags
    )
}

resource "aws_route_table" "public_rt" {
    for_each = local.public_vpc

    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-${var.ou}-${each.value}-public-rt"},
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

# ******************************************************************************
# Routes
# ******************************************************************************

# Create routes for private route tables
# Create routes for private subnets to nat gws located in public subnets
resource "aws_route" "route_to_natgw" {
    for_each = local.public_subnets

    /* NOTE: Using zipmap here requires equal numbers of public and private subnets, or this will fail */
    route_table_id         = aws_route_table.private_rt[zipmap(keys(var.public_subnets), keys(var.private_subnets))[each.key]].id

    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
}

# Create routes for public route table
# Create routes for public subnets to igw
resource "aws_route" "route_to_igw" {
    for_each = local.public_vpc

    route_table_id          = aws_route_table.public_rt[each.key].id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw[each.key].id
}
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
    route_table_id  = aws_route_table.public_rt[var.cidr_block].id
}
