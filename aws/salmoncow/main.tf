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
# Create vpc and all necessary networking components
# ******************************************************************************

module "vpc" {
    source = "../modules/network/vpc/"

    cidr_block = "10.0.0.0/16"

    name = local.name
    tags = local.tags

# Create subnets

    private_subnets = {
        "us-east-1a" = "10.0.1.0/24",
        "us-east-1b" = "10.0.2.0/24"
    }

    public_subnets = {
        "us-east-1a" = "10.0.3.0/24",
        "us-east-1b" = "10.0.4.0/24"
    }

# Create route tables, routes, and association of route tables to subnets

}
