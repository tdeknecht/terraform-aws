# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "ou" {
  description = "(Required) A logical identifier for the Organizational Unit."
  type        = string
}

variable "certificate_domain_name" {
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

variable "validation_domain_name" {
  description = " (Optional) A Route 53 domain name for which validation records will be placed"
  type        = string
  default     = null
}

# imported cert

variable "private_key" {
  description = "(Required) The certificate's PEM-formatted private key"
  type        = string
  default     = null
}

variable "certificate_body" {
  description = "(Required) The certificate's PEM-formatted public key"
  type        = string
  default     = null
}

variable "certificate_chain" {
  description = "(Optional) The certificate's PEM-formatted chain"
  type        = string
  default     = null
}
