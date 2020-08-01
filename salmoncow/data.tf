# ------------------------------------------------------------------------------
# Providers, Locals, etc.
# ------------------------------------------------------------------------------

provider "aws" {
  region  = local.region
  profile = "default"
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
