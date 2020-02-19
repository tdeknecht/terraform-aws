# ******************************************************************************
# Required inputs
# ******************************************************************************

variable cidr_block {
    description = "VPC CIDR"
}

variable ou {
    description = "organizational unit identifier"
}

variable name {
    description = "global name"
}

variable tags {
    description = "resource tags"
}

# ******************************************************************************
# Optional inputs
# ******************************************************************************

variable nat_gw {
    description = "A bool to identify whether NAT GWs should be created in each public subnet"
    default     =  false
}

variable private_subnets {
    description = "map of private subnets"
    default     = {}
}

variable public_subnets {
    description = "map of public subnets"
    default     = {}
}
