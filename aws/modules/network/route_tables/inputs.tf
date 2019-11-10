# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
    description     = "VPC ID"
    type            = string
}

variable private_subnets {
    description     = "map of private subnets"
    type            = list
}

variable public_subnets {
    description     = "map of public subnets"
    type            = list
}

variable name {
    description     = "global name"
    type            = string
}

variable tags {
    description     = "resource tags"
    type            = map(string)
}
