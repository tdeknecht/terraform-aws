# ------------------------------------------------------------------------------
# variables, locals, etc.
# ------------------------------------------------------------------------------

variable "aws_account_id" {
  type = string
}

variable "aws_account_admin" {
  type = string
}

locals {
  region   = "us-east-1"
  ou       = "dev"
  use_case = "000"

  tags = {
    "deployment" = "terraform"
    "owner"      = "td"
    "use_case"   = local.use_case
  }
}
