# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
    description     = "VPC ID"
}

# TODO: I won't always want to pass in the default network acl ID. I want this module to be dynamic.
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

variable use_case {
    description     = "global use case name"
}

variable tags {
    description     = "resource tags"
}
