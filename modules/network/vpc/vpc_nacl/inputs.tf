# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "ou" {
  description = "(Required) A logical identifier for the Organizational Unit."
  type        = string
}

variable "use_case" {
  description = "(Required) A friendly identifier of the use case."
  type        = string
}

variable "tags" {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

variable "vpc_id" {
  description = "(Required) VPC ID"
  type        = string
}

# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "private_subnet_ids" {
  description = "(Optional) A list of private subnets."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "(Optional) A list of public subnets."
  type        = list(string)
  default     = []
}

variable "internal_subnet_ids" {
  description = "(Optional) A list of internal subnets."
  type        = list(string)
  default     = []
}
