variable "region" {}
variable "ou" {}
variable "use_case" {}

locals {
  region   = var.region
  ou       = var.ou
  use_case = var.use_case

  tags = {
    "terraform" = true
    "owner"     = "/terraform-aws/dev"
    "tenant"    = "dev"
    "use_case"  = var.use_case
    "workspace" = terraform.workspace
  }
}