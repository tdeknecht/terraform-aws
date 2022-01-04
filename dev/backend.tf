terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
    tfe = {
      version = "~> 0.27.0"
    }
  }

  # requires `terraform login` or CLI config-file:credentials block (https://www.terraform.io/cli/config/config-file#credentials)
  cloud {
    organization = "tdeknecht-org"

    workspaces {
      tags = ["td000", "dev"]
    }
  }
}

resource "tfe_organization" "tdeknecht" {
  name  = "tdeknecht-org"
  email = "tdeknecht@gmail.com"
}
