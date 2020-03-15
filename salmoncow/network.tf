# ******************************************************************************
# VPC construct
# ******************************************************************************

# Create VPC
module "vpc_one" {
    source = "../modules/network/vpc/vpc_init/"

    ou        = local.ou
    use_case  = local.use_case
    tags      = local.tags

    cidr_block      = "10.0.0.0/16"

    private_subnets = { "10.0.0.0/24" = "us-east-1a", "10.0.1.0/24" = "us-east-1b" } # TODO: allow literal AZ as well as logical (default)
    public_subnets  = { "10.0.2.0/24" = "us-east-1a", "10.0.3.0/24" = "us-east-1b" }

    # nat_gw = true   # A flag to indicate whether you want to drop in NAT GWs and routing

    # internal_subnets = { "100.64.0.0/14" = "us-east-1a" } # TODO: Add this

    /* NOTE: The code for public_subnets and NAT GWs is bound together. If I wanted to deploy more than one NAT GW per public subnet, I can't do that right now. I can achieve greater flexibility in my NAT GW deployments if I make that its own module. */
}

# Create VPC NACLs
module "vpc_one_nacl" {
    source = "../modules/network/vpc/nacl/"

    ou        = local.ou
    use_case  = local.use_case
    tags      = local.tags

    vpc_id              = module.vpc_one.vpc_id
    
    private_subnet_ids  = module.vpc_one.private_subnet_ids
    public_subnet_ids   = module.vpc_one.public_subnet_ids
}
