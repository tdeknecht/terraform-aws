# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

# vpc_one
module "vpc_one" {
  source = "../modules/network/vpc/vpc_init/"

  ou                      = local.ou
  use_case                = local.use_case
  segment                 = "dev1"
  cidr_block              = "172.24.1.0/24"
  secondary_cidr_blocks   = ["172.24.0.0/26", "100.64.0.0/16"]
  private_subnets         = { "172.24.1.0/25" = "us-east-1a", "172.24.1.128/25" = "us-east-1b" }
  public_subnets          = { "172.24.0.0/28" = "us-east-1a", "172.24.0.16/28" = "us-east-1b" }
  internal_subnets        = { "100.64.0.0/17" = "us-east-1a", "100.64.128.0/17" = "us-east-1b" }
  map_public_ip_on_launch = true
  # nat_gw                  = true 
  tags = local.tags
}
output "vpc_id" { value = module.vpc_one.vpc_id }
output "private_subnet_ids" { value = module.vpc_one.private_subnet_ids }
output "public_subnet_ids" { value = module.vpc_one.public_subnet_ids }
output "internal_subnet_ids" { value = module.vpc_one.internal_subnet_ids }

module "vpc_one_nacl" {
  source = "../modules/network/vpc/vpc_nacl/"

  depends_on = [module.vpc_one.vpc_id] # depending on the entire module caused a rebuild even if something as simple as tags were changed

  ou                  = local.ou
  use_case            = local.use_case
  segment             = module.vpc_one.segment
  vpc_id              = module.vpc_one.vpc_id
  private_subnet_ids  = module.vpc_one.private_subnet_ids
  public_subnet_ids   = module.vpc_one.public_subnet_ids
  internal_subnet_ids = module.vpc_one.internal_subnet_ids
  tags                = local.tags
}

# ------------------------------------------------------------------------------
# EC2: Linux 2 HVM, SSD
# ------------------------------------------------------------------------------
# module "aws_linux2_1" {
#   source = "../modules/compute/ec2/"

#   ou                     = local.ou
#   use_case               = local.use_case
#   subnet_id              = module.vpc_one.public_subnet_ids[0]
#   security_group_ids     = [module.vpc_one.default_security_group_id]
#   iam_instance_profile   = aws_iam_instance_profile.base_ec2_assume_role.name
#   user_data              = file("./user_data/apache.sh")
#   # public_ip              = true
#   # ssh_from_my_ip         = true
#   tags                   = local.tags
# }


# ------------------------------------------------------------------------------
# EC2: public instance using CloudFormation
# ------------------------------------------------------------------------------

# EC2 using AWS CloudFormation EC2 module. Module S3 location
# resource "aws_s3_bucket_object" "cfm_ec2_public" {
#   bucket = module.s3_bucket_salmoncow.id
#   key    = "cloudformation_stacks/ec2_public.yaml"
#   source = "../../cloudformation/ec2_public.yaml"
#   etag   = filemd5("../../cloudformation/ec2_public.yaml")

#   tags = local.tags
# }

# Learn our public IP address. Use this for the SSH rule for the instance
# data "http" "checkip" { url = "http://icanhazip.com" }
# output "my_public_ip" { value = chomp(data.http.checkip.body) }

# EC2 using AWS CloudFormation EC2 module
# resource "aws_cloudformation_stack" "public_ec2" {
#   depends_on = [aws_s3_bucket_object.cfm_ec2_public]

#   name         = "public-ec2"
#   template_url = format("https://%s.s3.amazonaws.com/%s", module.s3_bucket_salmoncow.id, aws_s3_bucket_object.cfm_ec2_public.id)
#   tags         = local.tags

#   parameters = {
#     RegionId    = local.region
#     VpcIdParm   = module.vpc_one.vpc_id
#     SubnetId    = module.vpc_one.public_subnet_ids[0]
#     KeyName     = "aws_salmoncow"
#     SSHLocation = chomp(data.http.checkip.body)
#   }
# }
# output cloudformation_ec2_public { value = aws_cloudformation_stack.public_ec2.outputs }

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

resource "aws_iam_group_policy_attachment" "admin_pass_role" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.pass_role.arn
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
# IAM: Users, User Policies, User Policy Attachments, and Group Associations
# ------------------------------------------------------------------------------

# admin
resource "aws_iam_user" "admin" {
  name = var.aws_account_admin
  tags = local.tags
}

resource "aws_iam_user_group_membership" "admin" {
  user = aws_iam_user.admin.name
  groups = [
    aws_iam_group.admin.name,
    aws_iam_group.billing.name,
  ]
}

# citl
resource "aws_iam_user" "citl" {
  name = "citl"
  tags = local.tags
}

data "aws_iam_policy_document" "citl" {
  statement {
    sid     = "citlPolicy"
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::citl.club",
      "arn:aws:s3:::citl.club/*",
    ]
  }
}

resource "aws_iam_policy" "citl" {
  name        = "citl"
  description = "Manage CITL resources"
  policy      = data.aws_iam_policy_document.citl.json
}

resource "aws_iam_user_policy_attachment" "citl" {
  user       = aws_iam_user.citl.name
  policy_arn = aws_iam_policy.citl.arn
}


# nas-glacier-backup
resource "aws_iam_user" "nas_glacier_backup" {
  name = "nas-glacier-backup"
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "nas_glacier_backup" {
  user       = aws_iam_user.nas_glacier_backup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonGlacierFullAccess"
}

# ------------------------------------------------------------------------------
# IAM: Roles
# ------------------------------------------------------------------------------

# admin-role
resource "aws_iam_role" "admin_role" {
  name               = "admin-role"
  assume_role_policy = data.aws_iam_policy_document.admin_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "admin_assume_role" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "admin_assume_role" {
  statement {
    sid     = "adminAssumeRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.admin.arn]
    }
  }
}

# base-ec2-role
resource "aws_iam_role" "base_ec2_role" {
  name               = "base-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.base_ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "base_ec2_assume_role" {
  name = "base-ec2-role"
  role = aws_iam_role.base_ec2_role.name
}

data "aws_iam_policy_document" "base_ec2_assume_role" {
  statement {
    sid     = "ec2AssumeRolePolicy"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ------------------------------------------------------------------------------
# IAM: Policies
# ------------------------------------------------------------------------------

# passRole
data "aws_iam_policy_document" "pass_role" {
  statement {
    sid     = "adminGroupPassRolePolicy"
    effect  = "Allow"
    actions = [
      "iam:PassRole",
      "iam:ListInstanceProfiles",
      "ec2:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pass_role" {
  name   = "passRolePolicy"
  policy = data.aws_iam_policy_document.pass_role.json
}