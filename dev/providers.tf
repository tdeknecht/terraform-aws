provider "aws" {
  region  = var.region

  assume_role {
    role_arn    = "arn:aws:iam::678856875282:role/td001-dev-scalr-deployer-role"
    external_id = "N1k5aaWcxrsJhu7Q"
  }
}
