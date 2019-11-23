provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    tags = {
        deployment  = "terraform"
    }
}

# ******************************************************************************
# Create vpc and all necessary networking components
# ******************************************************************************

module "salmoncow" {
    source = "../modules/network/vpc/"

    name = "salmoncow"
    tags = local.tags

    cidr_block      = "10.0.0.0/16"
    private_subnets = { "us-east-1a" = "10.0.1.0/24", "us-east-1b" = "10.0.2.0/24" }
    #public_subnets  = { "us-east-1a" = "10.0.3.0/24", "us-east-1b" = "10.0.4.0/24" }

}
