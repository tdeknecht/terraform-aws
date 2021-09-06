locals {
  build_public = length(var.public_subnet_ids) > 0 ? 1 : 0
  build_private = length(var.private_subnet_ids) > 0 ? 1 : 0
  build_internal = length(var.internal_subnet_ids) > 0 ? 1 : 0
}

# ------------------------------------------------------------------------------
# Create Network ACLs
# ------------------------------------------------------------------------------

data "aws_vpc" "this_vpc" {
  id = var.vpc_id
}

# Private Network ACL (https://www.terraform.io/docs/providers/aws/r/network_acl.html)
resource "aws_network_acl" "nacl_private" {
  count = local.build_private

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  tags = merge(
    { 
      "Name" = "${var.use_case}-${var.segment}-private-nacl"
    },
    var.tags
  )
}

# Public Network ACL
resource "aws_network_acl" "nacl_public" {
  count = local.build_public

  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  tags = merge(
    { 
      "Name" = "${var.use_case}-${var.segment}-public-nacl"
    },
    var.tags
  )
}

# Internal Network ACL
resource "aws_network_acl" "nacl_internal" {
  count = local.build_internal

  vpc_id     = var.vpc_id
  subnet_ids = var.internal_subnet_ids

  tags = merge(
    { 
      "Name" = "${var.use_case}-${var.segment}-internal-nacl"
    },
    var.tags
  )
}

# ------------------------------------------------------------------------------
# Create Network ACLs: PRIVATE Subnets
# ------------------------------------------------------------------------------

# Create Network ACLs: PRIVATE INBOUND
resource "aws_network_acl_rule" "private_inbound_100" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_inbound_110" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_inbound_120" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Create Network ACLs: PRIVATE OUTBOUND
resource "aws_network_acl_rule" "private_outbound_100" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_outbound_110" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_outbound_120" {
  count = local.build_private

  network_acl_id = aws_network_acl.nacl_private[0].id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# ------------------------------------------------------------------------------
# Create Network ACLs: PUBLIC Subnets
# ------------------------------------------------------------------------------

# Create Network ACLs: PUBLIC INBOUND
resource "aws_network_acl_rule" "public_inbound_100" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_inbound_110" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_120" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_inbound_130" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# Create Network ACLs: PUBLIC OUTBOUND
resource "aws_network_acl_rule" "public_outbound_100" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_outbound_110" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_outbound_120" {
  count = local.build_public

  network_acl_id = aws_network_acl.nacl_public[0].id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# ------------------------------------------------------------------------------
# Create Network ACLs: INTERNAL Subnets
# ------------------------------------------------------------------------------

# Create Network ACLs: INTERNAL INBOUND
resource "aws_network_acl_rule" "internal_inbound_100" {
  count = local.build_internal

  network_acl_id = aws_network_acl.nacl_internal[0].id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
}

# Create Network ACLs: INTERNAL OUTBOUND
resource "aws_network_acl_rule" "internal_outbound_100" {
  count = local.build_internal

  network_acl_id = aws_network_acl.nacl_internal[0].id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = data.aws_vpc.this_vpc.cidr_block
}
