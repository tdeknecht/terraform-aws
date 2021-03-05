variable "pgp_key" {}


# MODULE INPUTS

variable "user_name" {}
variable "group_name" {}
variable "tags" {}

# MODULE RESOURCES for_each

resource "aws_iam_user" "user" {
  for_each = toset(var.user_name)

  name = each.value
  tags = var.tags
}

resource "aws_iam_user_login_profile" "profile" {
  for_each = aws_iam_user.user

  user    = each.value.name
  pgp_key = var.pgp_key
}

resource "aws_iam_group" "group" {
  name = var.group_name
}

resource "aws_iam_user_group_membership" "membership" {
  for_each = aws_iam_user.user

  user = each.value.name

  groups = [
    aws_iam_group.group.name,
  ]
}

output "passwords" {
  value = {
      for user in var.user_name :
        user => aws_iam_user_login_profile.profile[user].encrypted_password
  }
}


# MODULE RESOURCES count

# resource "aws_iam_user" "user" {
#   count = length(var.user_name)

#   name = var.user_name[count.index]
#   tags = var.tags
# }

# resource "aws_iam_user_login_profile" "profile" {
#   count = length(aws_iam_user.user)

#   user    = aws_iam_user.user[count.index].name
#   pgp_key = var.pgp_key
# }

# resource "aws_iam_group" "group" {
#   name = var.group_name
# }

# resource "aws_iam_user_group_membership" "membership" {
#   count = length(aws_iam_user.user)

#   user = aws_iam_user.user[count.index].name

#   groups = [
#     aws_iam_group.group.name,
#   ]
# }