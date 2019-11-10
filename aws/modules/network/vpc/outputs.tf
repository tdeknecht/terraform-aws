# ******************************************************************************
# Outputs
# ******************************************************************************

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
    value = [
        for region, subnet in var.private_subnets:
            aws_subnet.private_subnet[region].id
    ]
}

output "public_subnet_ids" {
    value = [
        for region, subnet in var.public_subnets:
            aws_subnet.public_subnet[region].id
    ]
}

output "private_rt_id" {
    value = aws_route_table.private_rt.id
}

output "public_rt_id" {
    value = aws_route_table.public_rt.id
}
