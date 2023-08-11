provider "aws" {
  region  = var.region
}

variable "hostname" {}
variable "api_token" {}

provider scalr {
  hostname = var.hostname
  token    = var.api_token
}