
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# ------------------------------------------------------------------------------
# Random simple stuff
# ------------------------------------------------------------------------------

# output "location" { value = element(split("/", path.cwd), length(split("/", path.cwd))-1) }

# data "aws_region" "current" {}

# variable "hello" { default = "world" }
# output "hello" { value = var.hello }

# data "http" "checkip" { url = "http://icanhazip.com" }
# output "my_public_ip" { value = "${chomp(data.http.checkip.body)}/32" }


# ------------------------------------------------------------------------------
# CIDR play
# ------------------------------------------------------------------------------

# Hashicorp module for subnets: https://registry.terraform.io/modules/hashicorp/subnets/cidr/latest

# get all available AZs in our region
data "aws_availability_zones" "available_azs" {
  state = "available"
}

# variable "azs" { default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"] } # newbits = 3
# variable "azs" { default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e"] } # newbits = 3
variable "azs" { default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"] } # newbits = 2
# variable "azs" { default = ["us-east-1a", "us-east-1b", "us-east-1c"] } # newbits = 2
# variable "azs" { default = ["us-east-1a", "us-east-1b"] } # newbits = 1
# variable "azs" { default = ["us-east-1a"] } # newbits = 0

variable "newbits" { 
  default = 2
}

variable "cidr" { default = "172.24.0.0/24" }
variable "secondary_cidr_blocks" { default = ["172.24.128.0/26", "100.64.0.0/16"] }

variable "subnet_prefix_extension" { default = 4 }
variable "zone_offset" { default = 8 }

locals {
  # I pulled this snippet from https://itnext.io/build-an-eks-cluster-with-terraform-d35db8005963, which I thought was pretty cool
  # private_subnets = [
  #   # this loop will create a one-line list as ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", ...]
  #   # with a length depending on how many Zones are available
  #   for zone_id in data.aws_availability_zones.available_azs.zone_ids :
  #   cidrsubnet(var.cidr, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  # ]
  # public_subnets = [
  #   # this loop will create a one-line list as ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", ...]
  #   # with a length depending on how many Zones are available
  #   # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
  #   for zone_id in data.aws_availability_zones.available_azs.zone_ids :
  #   cidrsubnet(var.cidr, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  # ]

  private_subnets = [
    for index, zone_id in var.azs :
    # cidrsubnet(var.cidr, length(var.azs) - 1, index)
    cidrsubnet(var.cidr, var.newbits, index)
  ]

  public_subnets = [
    for index, zone_id in var.azs :
    cidrsubnet(var.secondary_cidr_blocks[0], 2, index) # newbits stays at 2 because we only do /26s for the publics and increment by 2
  ]

  intra_subnets = [
    for index, zone_id in var.azs :
    cidrsubnet(var.secondary_cidr_blocks[1], var.newbits, index)
  ]
}

# cidrsubnet(prefix, newbits, netnum)
# prefix must be given in CIDR notation, as defined in RFC 4632 section 3.1.
# newbits is the number of additional bits with which to extend the prefix. For example, if given a prefix ending in /16 and a newbits value of 4, the resulting subnet address will have length /20.
# netnum is a whole number that can be represented as a binary integer with no more than newbits binary digits, which will be used to populate the additional bits added to the prefix.
# output "cidrsubnet" {
#   value = cidrsubnet("172.24.0.0/23", 0, 0)
# }

# output "azs" { value = var.azs }
output "available_zone_ids" { value = data.aws_availability_zones.available_azs.zone_ids }
output "available_zone_names" { value = data.aws_availability_zones.available_azs.names }
output "private_subnets" { value = local.private_subnets }
output "public_subnets" { value = local.public_subnets }
output "intra_subnets" { value = local.intra_subnets }

# ------------------------------------------------------------------------------
# stack overflow
# ------------------------------------------------------------------------------

# variable "server_ip_configs" {
#   default = {
#     mgmt               = { ct = "1" }
#     applicationgateway = { ct = "1" }
#     monitor            = { ct = "1" }
#     app                = { ct = "3" }
#   }
# }

# locals {
#   server_ip_configs_mapped = flatten([
#     for server, count in var.server_ip_configs : [
#       for i in range(count.ct) : {
#         "name" = join("-", [server, i+1])
#       }
#     ]
#   ])
# }

# output server_ip_configs_mapped { value = local.server_ip_configs_mapped }

# ------------------------------------------------------------------------------
# http provider testing
# ------------------------------------------------------------------------------
# data "http" "aws_ips" {
#   url = "https://ip-ranges.amazonaws.com/ip-ranges.json"

#   request_headers = {
#     Accept = "application/json"
#   }
# }

# # output aws_ips { value = jsondecode(data.http.aws_ips.body)["prefixes"][0]["service"] }

# output aws_ips {
#   value = distinct([
#     for item in jsondecode(data.http.aws_ips.body)["prefixes"] :
#     item["ip_prefix"] if item["service"] == "ROUTE53_HEALTHCHECKS" && item["region"] == "us-east-1"
#   ])
# }


# data "aws_ip_ranges" "r53_health_checkers" {
#   regions  = ["us-east-1", "us-west-2"]
#   services = ["ROUTE53_HEALTHCHECKS"]
# }

# output r53_health_checkers_cidrs { 
#     value = data.aws_ip_ranges.r53_health_checkers.cidr_blocks
# }

# ------------------------------------------------------------------------------
# playing with for_each and building maps for it
# ------------------------------------------------------------------------------

# variable cgw_configs {
#   default = {
#     cgw-id001 = [
#       ["10.0.0.1/30", "10.0.0.2/30"], # Tunnel pair 1
#       ["10.0.0.2/30", "10.0.0.3/30"], # Tunnel pair 2
#       ["10.0.0.4/30", "10.0.0.5/30"], # Tunnel pair 3
#       ["10.0.0.6/30", "10.0.0.7/30"], # Tunnel pair 4
#     ],
#     cgw-id002 = [
#       ["10.0.0.0/30", "10.0.0.1/30"], # Tunnel pair 1
#       ["10.0.0.2/30", "10.0.0.3/30"], # Tunnel pair 2
#       ["10.0.0.4/30", "10.0.0.5/30"], # Tunnel pair 3
#       ["10.0.0.6/30", "10.0.0.7/30"], # Tunnel pair 4
#     ],
#   }
# }

# locals {
#   name = "sandbox"

#   private_subnets = { "10.0.1.0/24" = "us-east-1a", "10.0.2.0/24" = "us-east-1b" }
#   public_subnets  = { "10.0.3.0/24" = "us-east-1c", "10.0.4.0/24" = "us-east-1d" }
#   #public_subnets = {}

#   is_public = local.public_subnets != {} ? { (data.aws_region.current.name) = local.name } : {}

#   nat_routes = tostring(zipmap(keys(local.public_subnets), keys(local.private_subnets))["10.0.3.0/24"])


#   # ---------------------------------------------------
#   build_vpn = true # get rid of this. the for_each won't run if you pass it an empty map

#   listmap = [
#     for cgw_id, tunnels in var.cgw_configs : {
#       for index, ips in tunnels :
#       format("%s-vpntunnel-%s", cgw_id, index) =>
#       length(ips) % 2 == 0 ? [format("%s", cgw_id), ips] # If two IPs are passed in, use them
#       : [format("%s", cgw_id), ["", ""]]                 # Else create two null IPs and hope for the best
#     }
#   ]


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
  # map = length(local.listmap) == 2 ? merge(local.listmap[0], local.listmap[1]) : merge(local.listmap[0])
# }

# output "nat_routes" { value = local.nat_routes }

# output "listmap" { value = local.listmap } 

# output "map" { value = local.map }
