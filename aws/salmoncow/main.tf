provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    ou = "test"

    tags = {
        deployment  = "terraform"
    }
}

# ******************************************************************************
# Create vpc and all necessary networking components
# ******************************************************************************

module "salmoncow" {
    source = "../modules/network/vpc/"

    ou      = local.ou
    name    = "salmoncow"
    tags    = local.tags

    /* TODO: Right now if I add another subnet to a similarly named AZ, it'll overwrite it. Fix this by flipping or renaming them? */

    cidr_block      = "10.0.0.0/16"
    private_subnets = { "10.0.1.0/24" = "us-east-1a", "10.0.2.0/24" = "us-east-1b" }
    public_subnets  = { "10.0.3.0/24" = "us-east-1c", "10.0.4.0/24" = "us-east-1d" }
    #private_subnets = { "us-east-1a" = "10.0.1.0/24", "us-east-1b" = "10.0.2.0/24", "us-east-1a" = "100.64.0.0/16" }
    #public_subnets  = { "us-east-1a" = "10.0.3.0/24", "us-east-1b" = "10.0.4.0/24" }

}
