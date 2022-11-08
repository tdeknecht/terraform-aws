terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
  }

  backend "remote" {
    hostname = "tdeknecht.scalr.io"
    organization = "dev"
    workspaces {
      name = "terraform-aws"
    }
  }
}
