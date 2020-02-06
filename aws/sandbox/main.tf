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


    # ---------------------------------------------------
    build_vpn = true
    cgw_ids = ["cgw-id001", "cgw-id002"]
    vpn_connections = 4

    listmap = local.build_vpn ? [
        for cgw in local.cgw_ids: {
            for vpns in range(local.vpn_connections):
                format("%s-vpn-%s", cgw, vpns) => cgw
        }
    ] : []

    map = merge(local.listmap...)

    /* OUTPUTS:
    map = {
        "cgw-id001-vpn-0" = "cgw-id001"
        "cgw-id001-vpn-1" = "cgw-id001"
        "cgw-id001-vpn-2" = "cgw-id001"
        "cgw-id001-vpn-3" = "cgw-id001"
        "cgw-id002-vpn-0" = "cgw-id002"
        "cgw-id002-vpn-1" = "cgw-id002"
        "cgw-id002-vpn-2" = "cgw-id002"
        "cgw-id002-vpn-3" = "cgw-id002"
    }   
    */
    # ---------------------------------------------------
}

#output "nat_routes" { value = local.nat_routes }
output "map" { value = local.map }
