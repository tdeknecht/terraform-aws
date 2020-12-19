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

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = ""
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Defaults to `private`. Conflicts with grant."
  type        = string
  default     = "private"
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document."
  type        = string
  default     = ""
}

variable "versioning" {
  description = "(Optional) A state of versioning."
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration" {
  description = "(Optional) Specifies when noncurrent object versions expire."
  type        = number
  default     = 90
}

variable "base_lifecycle_rule" {
  description = "(Optional) The base configuration of object lifecycle management for whole bucket. Deletes previous versions after 90 days."
  type        = bool
  default     = false
}

variable "mfa_delete" {
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. This cannot be used to toggle this setting but is available to allow managed buckets to reflect the state in AWS."
  type        = bool
  default     = false
}

# public access
variable "block_public_acls" {
  description = "(Optional) Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "(Optional) Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "(Optional) Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = " (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

# website
variable "index_document" {
  description = "(Required, unless using `redirect_all_requests_to`) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders."
  type        = string
  default     = ""
}

variable "error_document" {
  description = "(Optional) An absolute path to the document to return in case of a 4XX error."
  type        = string
  default     = ""
}

variable "redirect_all_requests_to" {
  description = "(Optional) A hostname to redirect all website requests for this bucket to."
  type        = string
  default     = ""
}

variable "routing_rules" {
  description = "Optional) A json array containing routing rules describing redirect behavior and when redirects are applied."
  type        = string
  default     = ""
}

# CORS

variable "cors_allowed_headers" {
  description = "(Optional) Specifies which headers are allowed."
  type        = list(string)
  default     = null
}

variable "cors_allowed_methods" {
  description = "(Required) Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD."
  type        = list(string)
  default     = []
}

variable "cors_allowed_origins" {
  description = "(Required) Specifies which origins are allowed."
  type        = list(string)
  default     = []
}

variable "cors_expose_headers" {
  description = "(Optional) Specifies expose header in the response."
  type        = list(string)
  default     = null
}

variable "cors_max_age_seconds" {
  description = "(Optional) Specifies time in seconds that browser can cache the response for a preflight request."
  type        = number
  default     = null
}
