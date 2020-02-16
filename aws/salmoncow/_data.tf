# ******************************************************************************
# Providers, Locals, etc.
# ******************************************************************************

provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    ou = "test"

    tags = {
        deployment  = "terraform"
        owner       = "salmoncow"
    }
}
