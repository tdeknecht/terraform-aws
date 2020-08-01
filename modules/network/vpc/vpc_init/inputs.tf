# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable cidr_block {
  description = "(Required) The CIDR block for the VPC."
  type        = string
}

variable ou {
  description = "(Required) A logical identifier for the Organizational Unit."
  type        = string
}

variable use_case {
  description = "(Required) A friendly identifier of the use case."
  type        = string
}

variable tags {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable secondary_cidr_blocks {
  description = "(Optional) A set of additional CIDR blocks to associate with the VPC."
  type        = set(string)
  default     = []
}

variable nat_gw {
  description = "(Optional) A bool to identify whether NAT GWs should be created in each public subnet."
  type        = bool
  default     = false
}

variable map_public_ip_on_launch {
  description = "(Optional) Used in public subnets, this will map a public IP to any instance deployed to the subnet."
  type        = bool
  default     = false
}

variable private_subnets {
  description = "(Optional) A map of private subnets in CIDR notation with a corresponding Availability Zone (e.g. '10.0.0.0/24' = 'us-east-1a')."
  type        = map(string)
  default     = {}
}

variable public_subnets {
  description = "(Optional) A map of public subnets in CIDR notation with a corresponding Availability Zone (e.g. '10.0.0.0/24' = 'us-east-1a')."
  type        = map(string)
  default     = {}
}

variable internal_subnets {
  description = "(Optional) A map of internal subnets in CIDR notation with a corresponding Availability Zone (e.g. '10.0.0.0/24' = 'us-east-1a')."
  type        = map(string)
  default     = {}
}
