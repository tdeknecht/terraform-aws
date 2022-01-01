terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }
  }

  cloud {
    organization = "tdeknecht-org"
    workspaces {
      tags = ["dev"]
    }
  }

  # backend "s3" {
  #   bucket  = "td000"
  #   key     = "terraform-state/td000.tfstate"
  #   region  = "us-east-1"
  #   profile = "default"
  # }
}