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

data "aws_iam_policy_document" "service_linked_roles" {
  statement {
    sid     = "modifyServiceLinkedRoles"
    effect  = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:UpdateRoleDescription",
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/*"]
  }
}

resource "aws_iam_policy" "service_linked_roles" {
  name        = "modify-service-linked-roles"
  description = "Manage IAM Service Linked Roles"
  policy      = data.aws_iam_policy_document.service_linked_roles.json
}

resource "aws_iam_group_policy_attachment" "service_linked_roles" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.service_linked_roles.arn
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

resource "aws_iam_role_policy_attachment" "base_ec2_role_ssm" {
  role       = aws_iam_role.base_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
# IAM: Service Linked Roles
# ------------------------------------------------------------------------------

# ssm
resource "aws_iam_service_linked_role" "ssm" {
  aws_service_name = "ssm.amazonaws.com"
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