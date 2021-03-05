provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

variable "aws_account_admin" {
  type = string
}

# RESOURCE IMPORT

# resource "aws_iam_user" "bill" {
#   name = "bill"
#   tags = { "foo" = "bar" }
# }

# resource "aws_iam_user_login_profile" "bill" {
#   user    = aws_iam_user.bill.name
#   pgp_key = "keybase:bill"
# }

# MODULE IMPORT

module "iam" {
  source = "./modules/iam"

  pgp_key    = "keybase:${var.aws_account_admin}"
  user_name  = ["bill", "sady"]
  group_name = "demo"
  tags       = { "foo" = "bar" }
}

output "passwords" { value = module.iam.passwords }
