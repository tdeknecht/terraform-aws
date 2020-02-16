# ******************************************************************************
# VPC modules start here
# ******************************************************************************

# Create VPC
module "vpc-one" {
    source = "../modules/network/vpc/"
    ou     = local.ou
    name   = "salmoncow"
    tags   = local.tags

    cidr_block      = "10.0.0.0/16"

    /* TODO: Instead fo using the account based AZs, I could use the actual AZ ID so you can more precisely place your subnets */
    private_subnets = { "10.0.0.0/24" = "us-east-1a", "10.0.1.0/24" = "us-east-1b" }
    # public_subnets  = { "10.0.2.0/24" = "us-east-1a", "10.0.3.0/24" = "us-east-1b" }
    # internal_subnets = { "100.64.0.0/14" = "us-east-1a" } # TODO: Add this

    /* NOTE: The code for public_subnets and NAT GWs is bound together. If I wanted to deploy more than one NAT GW per public subnet, I can't do that right now. I can achieve greater flexibility in my NAT GW deployments if I make that its own module. */
}

# Create VPC NACLs
module "vpc-one-nacl" {
    source = "../modules/network/nacl/"
    ou     = local.ou
    name   = "salmoncow"
    tags   = local.tags

    vpc_id              = module.vpc-one.vpc_id
    private_subnet_ids  = module.vpc-one.private_subnet_ids
}
