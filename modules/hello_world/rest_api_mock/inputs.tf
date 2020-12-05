# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "ou" {
  description = "(Required) A logical identifier for the Organizational Unit."
  type        = string
}

variable "name" {
  description = "(Required) Name of the API. Will generate as format `<ou>-<accountAlias>-<region>-<NAME>-<apiType>-api`."
  type        = string
}

variable "tags" {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable "stages" {
  description = "(Optional) Set of additional API stages."
  type        = set(string)
  default     = []
}

variable "type" {
  description = "(Optional) Endpoint type. Supports EDGE, REGIONAL, or PRIVATE. Defaults to EDGE."
  type        = string
  default     = "EDGE"
}

variable "vpc_endpoint_ids" {
  description = "(Optional) A list of VPC Endpoint IDs. It is only supported for PRIVATE endpoint types."
  type        = set(string)
  default     = []
}