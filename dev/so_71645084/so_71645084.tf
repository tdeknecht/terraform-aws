variable "costcenter" { default = "foo" }

data "external" "file_last_updated" {
  program = ["bash", "${path.module}/so_71645084.sh", "${path.module}/so_71645084.tf"]
}

locals {
  common_tags = {
    costcenter  = var.costcenter
    environment = terraform.workspace
    lastupdate  = data.external.file_last_updated.result.lastupdated
  }
}

output "common_tags" { value = local.common_tags }