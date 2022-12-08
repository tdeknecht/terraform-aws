# ------------------------------------------------------------------------------
# Random simple stuff
# ------------------------------------------------------------------------------

output "location" { value = element(split("/", path.cwd), length(split("/", path.cwd)) - 1) }
output "location_full" { value = path.cwd }

# resource "null_resource" "cwd" {
#   provisioner "local-exec" {
#     command = "python3 ${path.cwd}/test.py"
#   }

#   triggers = {
#     always_run = tostring(timestamp())
#   }
# }

# ------------------------------------------------------------------------------
# https://stackoverflow.com/questions/71645084/terraform-how-can-we-update-a-tag-only-if-modification-is-detected
# ------------------------------------------------------------------------------
data "external" "lastupdated" {
  program = ["bash", "${path.module}/external.sh", "external.sh"]
}
output "lastupdated" { value = data.external.lastupdated.result.lastupdated }
