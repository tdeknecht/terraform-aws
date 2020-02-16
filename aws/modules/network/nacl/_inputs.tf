# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
    description     = "VPC ID"
    type            = string
}

variable private_subnet_ids {
    description     = "list of private subnets"
    default         = []
}

# variable public_subnet_ids {
#     description     = "list of public subnets"
#     default         = []
# }

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
