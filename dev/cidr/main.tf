provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

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

