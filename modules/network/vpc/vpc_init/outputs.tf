# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "default_network_acl_id" {
  value = aws_vpc.vpc.default_network_acl_id
}

output "private_subnet_ids" {
  value = [
    for subnet, az in var.private_subnets :
    aws_subnet.private_subnet[subnet].id
  ]
}

output "public_subnet_ids" {
  value = [
    for subnet, az in var.public_subnets :
    aws_subnet.public_subnet[subnet].id
  ]
}

output "internal_subnet_ids" {
  value = [
    for subnet, az in var.internal_subnets :
    aws_subnet.internal_subnet[subnet].id
  ]
}

output "private_rt_id" {
  value = aws_vpc.vpc.default_route_table_id
}

output "public_rt_id" {
  value = [
    for cidr, region in local.public_vpc :
    aws_route_table.public_rt[cidr].id
  ]
}

output "internal_rt_id" {
  value = [
    for cidr, az in var.internal_subnets :
    aws_route_table.internal_rt[cidr].id
  ]
}
