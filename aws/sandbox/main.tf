provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    #public_subnets  = { "us-east-1a" = "10.0.3.0/24", "us-east-1b" = "10.0.4.0/24" }
    public_subnets = {}

    is_public = local.public_subnets != {} ? true : false

    coun = local.is_public ? 1 : 0
}

output "is_public" { value = local.is_public }
output "count" { value = local.coun }
