# ******************************************************************************
# Create Network ACLs
# ******************************************************************************

data "aws_vpc" "this_vpc" {
    id = var.vpc_id
}

# Default Network ACL (https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)

# When Terraform first adopts the Default Network ACL, it immediately removes all rules in 
# the ACL. It then proceeds to create any rules specified in the configuration. This step 
# is required so that only the rules specified in the configuration are created.

# This resource treats its inline rules as absolute; only the rules defined inline are 
# created, and any additions/removals external to this resource will result in diffs being 
# shown. For these reasons, this resource is incompatible with the aws_network_acl_rule resource.

resource "aws_default_network_acl" "nacl_default" {
    default_network_acl_id = var.default_network_acl_id

    tags = merge(
        { Name = "${var.name}-${var.ou}-default-nacl" },
        var.tags
    )
}

# Private Network ACL (https://www.terraform.io/docs/providers/aws/r/network_acl.html)

resource "aws_network_acl" "nacl_private" {
    vpc_id      = var.vpc_id
    subnet_ids  = var.private_subnet_ids

    tags = merge(
        { Name = "${var.name}-${var.ou}-private-nacl" },
        var.tags
    )

}

# ******************************************************************************
# Create Network ACLs: INBOUND
# ******************************************************************************

resource "aws_network_acl_rule" "inbound_100" {
    network_acl_id = aws_network_acl.nacl_private.id
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 80
    to_port        = 80
}

resource "aws_network_acl_rule" "inbound_110" {
    network_acl_id = aws_network_acl.nacl_private.id
    rule_number    = 110
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 443
    to_port        = 443
}

# ******************************************************************************
# Create Network ACLs: OUTBOUND
# ******************************************************************************

resource "aws_network_acl_rule" "outbound_100" {
    network_acl_id = aws_network_acl.nacl_private.id
    rule_number    = 100
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 80
    to_port        = 80
}

resource "aws_network_acl_rule" "outbound_110" {
    network_acl_id = aws_network_acl.nacl_private.id
    rule_number    = 110
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 443
    to_port        = 443
}

