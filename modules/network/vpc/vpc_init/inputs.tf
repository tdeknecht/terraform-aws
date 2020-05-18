# ******************************************************************************
# Required inputs
# ******************************************************************************

variable cidr_block {
  description = "VPC CIDR"
}

variable ou {
  description = "organizational unit identifier"
}

variable use_case {
  description = "global use case name"
}

variable tags {
  description = "resource tags"
}

# ******************************************************************************
# Optional inputs
# ******************************************************************************

variable nat_gw {
  description = "A bool to identify whether NAT GWs should be created in each public subnet"
  default     = false
}

variable map_public_ip_on_launch {
  description = "Used in public subnets, this will map a public IP to any instance deployed to the subnet."
  default     = false
}

variable private_subnets {
  description = "map of private subnets"
  default     = {}
}

variable public_subnets {
  description = "map of public subnets"
  default     = {}
}

variable internal_subnets {
  description = "map of internal subnets, generally used for EKS"
  default     = {}
}