# ------------------------------------------------------------------------------
# stack overflow: https://stackoverflow.com/questions/65569177/how-to-iterate-through-nested-list-of-objects-in-terraform
# ------------------------------------------------------------------------------

# locals {
#   urls = toset(flatten([
#     for cm in var.cloud-configmap : [
#       for cm-file in cm.cm-files :
#         format("https://%s", cm-file.url)
#     ]
#   ]))
# }
# output "urls" { value = local.urls }

# variable "cloud-configmap" {
#   type = map(object({
#     name = string
#     namespace = string
#     cm-files = list(object({
#       url = string
#       data-keyname = string 
#     }))
#   }))
#   default = {
#     "cm1" = {
#       name = "cm-name"
#       namespace = "testnamespace"
#       cm-files = [{
#         url = "someurl.com/file1.yaml"
#         data-keyname = "file1.yml"
#       },
#       {
#         url = "someurl.com/file2.yaml"
#         data-keyname = "file2.yml"
#       }]
#     },
#     "cm2" = {
#       name = "cm-name2"
#       namespace = "default"
#       cm-files = [{
#         url = "someurl.com/file3.yaml"
#         data-keyname = "file3.yml"
#       },
#       {
#         url = "someurl.com/file4.yaml"
#         data-keyname = "file4.yml"
#       }]
#     }
#   }
# }

# data "http" "config-map" {
#   for_each = toset(flatten([
#     for cm in var.cloud-configmap : [
#       for cm-file in cm.cm-files :
#         cm-file.url
#     ]
#   ]))

#   url = format("https://%s", each.key)

#   request_headers = {
#     Accept = "text/plain"
#   }
# }

# resource "kubernetes_config_map" "configmap" {
#   for_each = var.cloud-configmap

#   metadata {
#     name = each.value.name
#     namespace = each.value.namespace
#   }

#   data = {
#     for cm-file in each.value.cm-files :
#       cm-file.url => cm-file.data-keyname
#   }
# }
