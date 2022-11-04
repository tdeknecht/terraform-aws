provider "aws" {
  region  = var.region

  assume_role {
    role_arn    = "arn:aws:iam::919814621061:user/scalr-saas"
    external_id = "BhgYExxs4u5fibK4"
  }
}
