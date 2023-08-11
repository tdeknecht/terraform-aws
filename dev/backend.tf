terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
    scalr = {
      source = "registry.scalr.io/scalr/scalr"
      version= "~> 1.0.0"
    }
  }

  backend "remote" {
    hostname = "tdeknecht.scalr.io"
    organization = "env-uajgog6bb98bnj8"
    workspaces {
      name = "terraform-aws"
    }
  }
}
