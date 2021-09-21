# variable "vpc_id" {}
# variable "create_webserver" { default = 2 }
# variable "name" { default = "so" }
# variable "elb_port" { default = 443 }

# data "aws_vpc" "this" {
#   id = var.vpc_id
# }

# data "aws_subnet_ids" "default" {
#   vpc_id = var.vpc_id

#   tags = {
#     network = "private"
#   }
# }

# resource "aws_security_group" "elb" {
#   count = var.create_webserver

#   name        = "${var.name}-${count.index}"
#   description = var.name
#   vpc_id      = var.vpc_id
#   tags = merge(
#     {
#       "Name" = var.name
#     },
#     local.tags
#   )

#   ingress {
#     description = "HTTPS"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.this.cidr_block]
#   }
# }

# resource "aws_elb" "webserver_example" {
#   count = var.create_webserver

#   name            = "${var.name}-${count.index}"
#   subnets         = data.aws_subnet_ids.default.ids
#   security_groups = [aws_security_group.elb[count.index].id]

#   listener {
#     instance_port     = 8000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
# }

# output "url" {
#   value = [
#     for dns_name in aws_elb.webserver_example.*.dns_name :
#     format("http://%s:%s", dns_name, var.elb_port)
#   ]
# }