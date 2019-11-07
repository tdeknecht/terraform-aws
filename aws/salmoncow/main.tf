provider "aws" {
    region = "us-east-1"

    profile = "default"
}

locals {

}

resource "aws_vpc" "salmoncow" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "salmoncow",
        terraform = "true"
    }
}
