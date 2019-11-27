data "aws_region" "current" {}

provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {
    name = "sandbox"

    private_subnets = { "10.0.1.0/24" = "us-east-1a", "10.0.2.0/24" = "us-east-1b" }
    public_subnets  = { "10.0.3.0/24" = "us-east-1c", "10.0.4.0/24" = "us-east-1d" }
    #public_subnets = {}

    is_public = local.public_subnets != {} ? { (data.aws_region.current.name) = local.name } : {}

    nat_routes = tostring(zipmap(keys(local.public_subnets), keys(local.private_subnets))["10.0.3.0/24"])
}

output "nat_routes" { value = local.nat_routes }
