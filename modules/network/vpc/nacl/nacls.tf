# ******************************************************************************
# Create Network ACLs
# ******************************************************************************

data "aws_vpc" "this_vpc" {
    id = var.vpc_id
}

# Private Network ACL (https://www.terraform.io/docs/providers/aws/r/network_acl.html)

resource "aws_network_acl" "nacl_private" {
    vpc_id      = var.vpc_id
    subnet_ids  = var.private_subnet_ids

    tags = merge(
        { Name = "${var.use_case}-${var.ou}-private-nacl" },
        var.tags
    )

}

# Public Network ACL

resource "aws_network_acl" "nacl_public" {
    vpc_id      = var.vpc_id
    subnet_ids  = var.public_subnet_ids

    tags = merge(
        { Name = "${var.use_case}-${var.ou}-public-nacl" },
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

