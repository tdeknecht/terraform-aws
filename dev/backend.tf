# ------------------------------------------------------------------------------
# S3 remote state backend
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket  = "salmoncow"
    key     = "terraform_state/dev_terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
