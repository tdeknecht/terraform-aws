provider "aws" {
  region  = var.region
  profile = "default"
}

provider "tfe" {
  token = var.tfe_user_token
}