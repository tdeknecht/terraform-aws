provider "aws" {
  region  = var.region

  assume_role {
    role_arn     = "arn:aws:iam::678856875282:role/td001-dev-scalr-deployer-role"
  }
}
