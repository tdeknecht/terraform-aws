# ******************************************************************************
# root outputs
# ******************************************************************************

output "vpc_id" { value = module.vpc-one.vpc_id }

output "private_subnet_ids" { value = module.vpc-one.private_subnet_ids }

output "public_subnet_ids"  { value = module.vpc-one.public_subnet_ids }