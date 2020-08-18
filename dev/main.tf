# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

# vpc_one
module "vpc_one" {
  source = "../modules/network/vpc/vpc_init/"

  ou                      = local.ou
  use_case                = local.use_case
  tags                    = local.tags
  cidr_block              = "10.0.0.0/16"
  secondary_cidr_blocks   = ["100.64.0.0/16"]
  private_subnets         = { "10.0.0.0/24" = "us-east-1a", "10.0.1.0/24" = "us-east-1b" }
  public_subnets          = { "10.0.2.0/24" = "us-east-1a", "10.0.3.0/24" = "us-east-1b" }
  internal_subnets        = { "100.64.0.0/17" = "us-east-1a", "100.64.128.0/17" = "us-east-1b" }
  map_public_ip_on_launch = true
  # nat_gw                  = true 
}
output "vpc_id" { value = module.vpc_one.vpc_id }
output "private_subnet_ids" { value = module.vpc_one.private_subnet_ids }
output "public_subnet_ids" { value = module.vpc_one.public_subnet_ids }
output "internal_subnet_ids" { value = module.vpc_one.internal_subnet_ids }

module "vpc_one_nacl" {
  source = "../modules/network/vpc/vpc_nacl/"

  depends_on = [module.vpc_one]

  ou                  = local.ou
  use_case            = local.use_case
  tags                = local.tags
  vpc_id              = module.vpc_one.vpc_id
  private_subnet_ids  = module.vpc_one.private_subnet_ids
  public_subnet_ids   = module.vpc_one.public_subnet_ids
  internal_subnet_ids = module.vpc_one.internal_subnet_ids
}

# ------------------------------------------------------------------------------
# S3: Buckets
# ------------------------------------------------------------------------------

# salmoncow
module "s3_bucket_salmoncow" {
  source = "../modules/storage/s3/s3_bucket/"

  ou                            = local.ou
  use_case                      = local.use_case
  bucket                        = "salmoncow"
  versioning                    = true
  noncurrent_version_expiration = 30
  base_lifecycle_rule           = true
  policy                        = data.aws_iam_policy_document.s3_bucket_policy_admin.json
  tags                          = local.tags
}

output "s3_salmoncow_id" { value = module.s3_bucket_salmoncow.id }
output "s3_salmoncow_arn" { value = module.s3_bucket_salmoncow.arn }

data "aws_iam_policy_document" "s3_bucket_policy_admin" {
  statement {
    sid       = "adminS3"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::salmoncow/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.admin_role.arn]
    }
  }
}

# ------------------------------------------------------------------------------
# IAM: Groups and Group Policies
# ------------------------------------------------------------------------------

# admin
resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# billing
resource "aws_iam_group" "billing" {
  name = "billing"
}

resource "aws_iam_group_policy_attachment" "billing" {
  group      = aws_iam_group.billing.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

# ------------------------------------------------------------------------------
# IAM: Users and Group Associations
# ------------------------------------------------------------------------------

# users
resource "aws_iam_user" "admin" {
  name = var.aws_account_admin
  tags = local.tags
}

resource "aws_iam_user_group_membership" "admin" {
  user   = aws_iam_user.admin.name
  groups = [
    aws_iam_group.admin.name,
    aws_iam_group.billing.name,
  ]
}

# ------------------------------------------------------------------------------
# IAM: Roles
# ------------------------------------------------------------------------------

# admin-role
resource "aws_iam_role" "admin_role" {
  name               = "admin-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "assumeRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.admin.arn]
    }
  }
}