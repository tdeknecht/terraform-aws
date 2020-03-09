# ******************************************************************************
# root outputs
# ******************************************************************************

output "vpc_id" { value = module.vpc_one.vpc_id }

output "private_subnet_ids" { value = module.vpc_one.private_subnet_ids }

output "public_subnet_ids"  { value = module.vpc_one.public_subnet_ids }