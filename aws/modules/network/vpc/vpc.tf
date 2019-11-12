# ******************************************************************************
# Create vpc
# ******************************************************************************

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block

    tags = merge(
        {Name = var.name},
        var.tags
    )
}

# ******************************************************************************
# Create Internet Gateway
# ******************************************************************************

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {Name = "${var.name}-igw"},
        var.tags
    )
}
