provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    name = "salmoncow"

    private_subnets = {
        "us-east-1a" = "10.0.1.0/24",
        "us-east-1b" = "10.0.2.0/24"
    }

    public_subnets = {
        "us-east-1a" = "10.0.3.0/24",
        "us-east-1b" = "10.0.4.0/24"
    }
}

resource "aws_vpc" "salmoncow" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = local.name,
        deployment = "terraform"
    }
}

resource "aws_subnet" "private" {
    for_each            = local.private_subnets

    vpc_id              = aws_vpc.salmoncow.id
    availability_zone   = each.key
    cidr_block          = each.value

    tags = {
        Name = "${local.name}-${each.key}-private-subnet",
        deployment = "terraform"
    }
}
