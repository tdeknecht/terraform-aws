# ******************************************************************************
# Required inputs
# ******************************************************************************

variable cidr_block {
    description     = "VPC CIDR"
    type            = string
}

variable private_subnets {
    description     = "map of private subnets"
    type            = map(string)
}

variable public_subnets {
    description     = "map of public subnets"
    type            = map(string)
}

variable name {
    description     = "global name"
    type            = string
}

variable tags {
    description     = "resource tags"
    type            = map(string)
}
