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
  type = string
  default = ""
}

variable acl {
  description = "(Optional) The canned ACL to apply. Defaults to `private`. Conflicts with grant."
  type = string
  default = "private"
}
