provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    name = "salmoncow"

    tags = {
        deployment  = "terraform"
    }
}

# ******************************************************************************
# Create vpc
# ******************************************************************************
module "vpc" {
    source = "../modules/network/vpc/"

    cidr_block = "10.0.0.0/16"

    name = local.name
    tags = local.tags
}

# ******************************************************************************
# Create subnets
# ******************************************************************************
module "subnets" {
    source = "../modules/network/subnets/"

    vpc_id = module.vpc.vpc_id

    private_subnets = {
        "us-east-1a" = "10.0.1.0/24",
        "us-east-1b" = "10.0.2.0/24"
    }

    public_subnets = {
        "us-east-1a" = "10.0.3.0/24",
        "us-east-1b" = "10.0.4.0/24"
    }

    name = local.name
    tags = local.tags
}

# ******************************************************************************
# Create route tables, routes, and association or route tables to subnets
# ******************************************************************************

module "route_tables" {
    source = "../modules/network/route_tables"

    vpc_id          = module.vpc.vpc_id
    private_subnets = module.subnets.private_subnet_ids
    public_subnets  = module.subnets.public_subnet_ids

    name = local.name
    tags = local.tags
}
