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

    tags = {
        deployment  = "terraform"
    }
}
/*
resource "aws_vpc" "salmoncow" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = local.name,
        deployment = "terraform"
    }
}
*/
module "vpc" {
    source = "../modules/vpc/"

    cidr_block = "10.0.0.0/16"

    name = local.name
    tags = local.tags
}

module "subnets" {
    source = "../modules/subnets/"

    vpc_id = module.vpc.vpc_id

    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets

    name = local.name
    tags = local.tags
}
