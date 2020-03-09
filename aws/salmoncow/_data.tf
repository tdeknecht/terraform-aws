# ******************************************************************************
# Providers, Locals, etc.
# ******************************************************************************

provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    ou       = "test"
    use_case = "salmoncow"

    tags = {
        deployment  = "terraform"
        owner       = "salmoncow"
    }
}
