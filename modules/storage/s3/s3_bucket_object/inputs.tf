# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable bucket_name {
  description = "Name of the S3 bucket. Must be DNS friendly"
}

variable path_to_object {
  description = "A path to the object being stored"
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
