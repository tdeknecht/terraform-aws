
data "aws_region" "current" {}

provider "aws" {
  region = "us-east-1"

  profile = "default"
}

# ******************************************************************************
# http provider testing
# ******************************************************************************
data "http" "aws_ips" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"

  request_headers = {
    Accept = "application/json"
  }
}

# output aws_ips { value = jsondecode(data.http.aws_ips.body)["prefixes"][0]["service"] }

output aws_ips {
  value = distinct([
    for item in jsondecode(data.http.aws_ips.body)["prefixes"] :
    item["ip_prefix"] if item["service"] == "ROUTE53_HEALTHCHECKS" && item["region"] == "us-east-1"
  ])
}


data "aws_ip_ranges" "r53_health_checkers" {
  regions  = ["us-east-1", "us-west-2"]
  services = ["ROUTE53_HEALTHCHECKS"]
}

# output r53_health_checkers_cidrs { 
#     value = data.aws_ip_ranges.r53_health_checkers.cidr_blocks
# }

# ******************************************************************************
# playing with for_each and building maps for it
# ******************************************************************************

variable cgw_configs {
  default = {
    cgw-id001 = [
      ["10.0.0.1/30", "10.0.0.2/30"], # Tunnel pair 1
      ["10.0.0.2/30", "10.0.0.3/30"], # Tunnel pair 2
      ["10.0.0.4/30", "10.0.0.5/30"], # Tunnel pair 3
      ["10.0.0.6/30", "10.0.0.7/30"], # Tunnel pair 4
    ],
    cgw-id002 = [
      ["10.0.0.0/30", "10.0.0.1/30"], # Tunnel pair 1
      ["10.0.0.2/30", "10.0.0.3/30"], # Tunnel pair 2
      ["10.0.0.4/30", "10.0.0.5/30"], # Tunnel pair 3
      ["10.0.0.6/30", "10.0.0.7/30"], # Tunnel pair 4
    ],
  }
}

locals {
  name = "sandbox"

  private_subnets = { "10.0.1.0/24" = "us-east-1a", "10.0.2.0/24" = "us-east-1b" }
  public_subnets  = { "10.0.3.0/24" = "us-east-1c", "10.0.4.0/24" = "us-east-1d" }
  #public_subnets = {}

  is_public = local.public_subnets != {} ? { (data.aws_region.current.name) = local.name } : {}

  nat_routes = tostring(zipmap(keys(local.public_subnets), keys(local.private_subnets))["10.0.3.0/24"])


  # ---------------------------------------------------
  build_vpn = true # get rid of this. the for_each won't run if you pass it an empty map

  listmap = [
    for cgw_id, tunnels in var.cgw_configs : {
      for index, ips in tunnels :
      format("%s-vpntunnel-%s", cgw_id, index) =>
      length(ips) % 2 == 0 ? [format("%s", cgw_id), ips] # If two IPs are passed in, use them
      : [format("%s", cgw_id), ["", ""]]                 # Else create two null IPs and hope for the best
    }
  ]


  /*
    cgw_ids = ["cgw-id001", "cgw-id002"]
    cgw1_vpn_tunnel1_ips = ["10.0.0.0", "10.0.0.2", "10.0.0.4", "10.0.0.6"]
    cgw1_vpn_tunnel2_ips = ["10.0.0.4", "10.0.0.6", "10.0.0.5", "10.0.0.7"]

    cgw2_vpn_tunnel1_ips = ["10.0.1.0", "10.0.1.2", "10.0.1.4", "10.0.1.6"]
    cgw2_vpn_tunnel2_ips = ["10.0.1.1", "10.0.1.3", "10.0.1.5", "10.0.1.7"]

    vpn_connections = 4
    #vpn_connections = length(local.cgw1_vpn_tunnel1_ips)

    listmap = local.build_vpn ? [
        for index, cgw in local.cgw_ids: {
            for vpns in range(local.vpn_connections):
                format("%s-vpn-%s", cgw, vpns) => 
                    index == 0 ? [ format("%s", cgw), [local.cgw1_vpn_tunnel1_ips[vpns], local.cgw1_vpn_tunnel2_ips[vpns]] ]
                               : [ format("%s", cgw), [local.cgw2_vpn_tunnel1_ips[vpns], local.cgw2_vpn_tunnel2_ips[vpns]] ]
        }
    ] : []
    */


  # Need to use this until the bug is fixed where input variables have an invalid type.
  # Once the bug is fixed, use this:   map = merge(local.listmap...)
  map = length(local.listmap) == 2 ? merge(local.listmap[0], local.listmap[1]) : merge(local.listmap[0])
}

# output "nat_routes" { value = local.nat_routes }

# output "listmap" { value = local.listmap } 

# output "map" { value = local.map }
