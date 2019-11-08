# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
    description     = "VPC ID"
    type            = string
}

variable private_subnets {
    description     = "private subnets"
    type            = map(string)
}

variable public_subnets {
    description     = "public subnets"
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
