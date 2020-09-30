# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "name" {
  description = "(Required) This is the name of the hosted zone."
  type        = string
}

variable "tags" {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable "comment" {
  description = "(Optional) A comment for the hosted zone. Defaults to 'Managed by Terraform'."
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy" {
  description = "(Optional) Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone."
  type        = bool
  default     = false
}

variable "vpc_init" {
  description = "(Optional) Configuration block(s) specifying VPC(s) to associate with a private hosted zone. Formatted as `{vpc = aws_region}`."
  type        = map(string)
  default     = {}
}

variable "vpc_secondary" {
  description = "(Optional) Additional configuration block(s) specifying VPC(s) to associate with a private hosted zone. Formatted as `{vpc = aws_region}`."
  type        = map(string)
  default     = {}
}