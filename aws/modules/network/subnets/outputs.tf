# ******************************************************************************
# Outputs
# ******************************************************************************

output "private_subnet_ids" {
    value = [
        for region, subnet in var.private_subnets:
            aws_subnet.private[region].id
    ]
}

output "public_subnet_ids" {
    value = [
        for region, subnet in var.public_subnets:
            aws_subnet.public[region].id
    ]
}
