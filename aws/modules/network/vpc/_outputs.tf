# ******************************************************************************
# Outputs
# ******************************************************************************

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
    value = [
        for subnet, az in var.private_subnets:
            aws_subnet.private_subnet[subnet].id
    ]
}

output "public_subnet_ids" {
    value = [
        for subnet, az in var.public_subnets:
            aws_subnet.public_subnet[subnet].id
    ]
}

output "private_rt_id" {
    value = aws_vpc.vpc.default_route_table_id
}

output "public_rt_id" {
    value = aws_route_table.public_rt[data.aws_region.current.name].id
}
