# ------------------------------------------------------------------------------
# stack overflow: https://stackoverflow.com/questions/69273821/build-a-map-from-conditional-output-values-in-terraform
# ------------------------------------------------------------------------------

variable "my_module" {
  default = {
    "instance_1" = {
      "key"       = "hello"
      "value"     = "world"
      "is_needed" = true
    }
    "instance_2" = {
      "key"       = "foo"
      "value"     = "bar"
      "is_needed" = true
    }
  }
}

locals {
  map_of_needed_values = tomap({
    for instance in var.my_module :
    instance.key => instance.value if instance.is_needed
  })
}

output "map_of_needed_values" { value = local.map_of_needed_values }
