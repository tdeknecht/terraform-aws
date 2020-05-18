# ******************************************************************************
# Required inputs
# ******************************************************************************

variable vpc_id {
  description = "VPC ID"
}

variable private_subnet_ids {
  description = "list of private subnets"
  default     = []
}

variable public_subnet_ids {
  description = "list of public subnets"
  default     = []
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
