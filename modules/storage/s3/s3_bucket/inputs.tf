# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

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

variable bucket {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = ""
}

variable acl {
  description = "(Optional) The canned ACL to apply. Defaults to `private`. Conflicts with grant."
  type        = string
  default     = "private"
}

variable policy {
  description = "(Optional) A valid bucket policy JSON document."
  type = string
  default = ""
}

variable block_public_acls {
  description = "(Optional) Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable block_public_policy {
  description = "(Optional) Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable ignore_public_acls {
  description = "(Optional) Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable restrict_public_buckets {
  description = " (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}
