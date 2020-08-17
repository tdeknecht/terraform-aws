# ------------------------------------------------------------------------------
# admin-role
# ------------------------------------------------------------------------------
resource "aws_iam_role" "admin_role" {
  name               = "admin-role"
  assume_role_policy = data.aws_iam_policy_document.base_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "admin_role_policy_attachment" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "base_role_policy" {
  statement {
    sid     = "adminSwitchRolePolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::117865246796:user/tdeknecht"]
    }
  }
}