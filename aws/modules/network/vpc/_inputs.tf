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
    default         = {}
}

variable public_subnets {
    description     = "map of public subnets"
    #type            = map(string) # BUG: If I define the type, it populates the variable with unknowns and counteracts by boolean logic
    default         = {}
}

variable ou {
    description     = "organizational unit identifier"
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
