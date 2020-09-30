# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "domain_name" {
  description = " (Required) A domain name for which the certificate should be issued"
  type        = string
}

variable "validation_method" {
  description = "(Required) Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  type        = string
}

variable "tags" {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable "subject_alternative_names" {
  description = "(Optional) Set of domains that should be SANs in the issued certificate."
  type        = set(string)
  default     = []
}


