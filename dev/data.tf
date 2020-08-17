# ------------------------------------------------------------------------------
# variables, locals, etc.
# ------------------------------------------------------------------------------

variable "aws_account_id" {
  type = string
}

locals {
  region   = "us-east-1"
  ou       = "test"
  use_case = "salmoncow"

  tags = {
    deployment = "terraform"
    owner      = "salmoncow"
  }
}
