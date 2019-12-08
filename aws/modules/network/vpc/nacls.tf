# ******************************************************************************
# Create Network ACLs
# ******************************************************************************

# Default Network ACL
resource "aws_default_network_acl" "nacl_default" {
    default_network_acl_id = aws_vpc.vpc.default_network_acl_id

    # No rules defined, block all ingress and egress

    tags = merge(
        {Name = "${var.name}-${var.ou}-default-nacl"},
        var.tags
    )
}

# Custom Network ACL
resource "aws_network_acl" "nacl_private" {
    vpc_id      = aws_vpc.vpc.id
    subnet_ids  = [
        for subnet, az in var.private_subnets:
            aws_subnet.private_subnet[subnet].id
    ]

    tags = merge(
        {Name = "${var.name}-${var.ou}-private-nacl"},
        var.tags
    )

    ingress {
        protocol    = "tcp"
        rule_no     = 100
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 80
        to_port     = 80
    }

    ingress {
        protocol    = "tcp"
        rule_no     = 200
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 443
        to_port     = 443
    }

    egress {
        protocol    = "all"
        rule_no     = 100
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 0
        to_port     = 0
    }
}
