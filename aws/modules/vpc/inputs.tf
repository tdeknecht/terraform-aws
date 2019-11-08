# ******************************************************************************
# Required inputs
# ******************************************************************************

variable cidr_block {
    description     = "VPC CIDR"
    type            = string
}

variable name {
    description     = "global name"
    type            = string
}

variable tags {
    description     = "resource tags"
    type            = map(string)
}
