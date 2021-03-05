# ------------------------------------------------------------------------------
# stack overflow https://stackoverflow.com/questions/62231050/terraform-dynamically-loop-over-elements-in-a-list-and-expand-based-on-values/
# ------------------------------------------------------------------------------

# variable "server_ip_configs" {
#   default = {
#     mgmt               = { ct = "1" }
#     applicationgateway = { ct = "1" }
#     monitor            = { ct = "1" }
#     app                = { ct = "3" }
#   }
# }

# locals {
#   server_ip_configs_mapped = flatten([
#     for server, count in var.server_ip_configs : [
#       for i in range(count.ct) : {
#         "name" = join("-", [server, i+1])
#       }
#     ]
#   ])
# }

# output server_ip_configs_mapped { value = local.server_ip_configs_mapped }