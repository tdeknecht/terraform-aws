variable "region" {}
variable "ou" {}
variable "use_case" {}
variable "tfe_user_token" {}
variable "somemap" {}
output "somemap" { value = var.somemap }

locals {
  region   = var.region
  ou       = var.ou
  use_case = var.use_case

  tags = {
    "terraform" = true
    "owner"     = "aws-terraform"
    "tenant"    = "dev"
    "use_case"  = var.use_case
    "workspace" = terraform.workspace
  }
}