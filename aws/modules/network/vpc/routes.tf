# ******************************************************************************
# Create route tables
# ******************************************************************************

# The VPC Default route table will be used as the private_rt and is declared as Main
resource "aws_default_route_table" "private_rt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    tags = merge(
        {Name = "${var.name}-private-rt"},
        var.tags
    )
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-public-rt"},
        var.tags
    )
}

# ******************************************************************************
# Create routes
# ******************************************************************************

# Create routes for private (main) route table
/*
# Create route for NAT Gateway
resource "aws_route" "private_rt_natgw_route" {
    route_table_id          = aws_vpc.vpc.main_route_table_id
    destination_cidr_block  = "0.0.0.0/0"
    #nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
*/



# Create routes for public route table
# Create routes for public route tables to igw
resource "aws_route" "public_rt_igw_route" {
    route_table_id          = aws_route_table.public_rt.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw.id
}

# ******************************************************************************
# Associate subnets with route tables
# ******************************************************************************

# Associate private subnet with private route table
resource "aws_route_table_association" "private_rt_assoc" {
    for_each        = aws_subnet.private_subnet

    subnet_id       = aws_subnet.private_subnet[each.key].id
    route_table_id  = aws_vpc.vpc.main_route_table_id
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_rt_assoc" {
    for_each        = aws_subnet.public_subnet

    subnet_id       = aws_subnet.public_subnet[each.key].id
    route_table_id  = aws_route_table.public_rt.id
}
