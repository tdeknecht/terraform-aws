# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
    description     = "VPC ID"
}

variable default_network_acl_id {
    description     = "default VPC nacl"
}

variable private_subnet_ids {
    description     = "list of private subnets"
    default         = []
}

variable public_subnet_ids {
    description     = "list of public subnets"
    default         = []
}

variable ou {
    description     = "organizational unit identifier"
}

variable name {
    description     = "global name"
}

variable tags {
    description     = "resource tags"
}
