# ------------------------------------------------------------------------------
# stack overflow: https://stackoverflow.com/questions/66499426/terraform-aws-iam-iterate-over-rendered-json-policies
# ------------------------------------------------------------------------------

# data "aws_iam_policy_document" "role_1" {

#   statement {
#     sid = "CloudFront1"

#     actions = [
#       "cloudfront:ListDistributions",
#       "cloudfront:ListStreamingDistributions"
#     ]
#     resources = ["*"]
#   }
# }

# data "aws_iam_policy_document" "role_2" {
#   statement {
#     sid = "CloudFront2"

#     actions = [
#       "cloudfront:CreateInvalidation",
#       "cloudfront:GetDistribution",
#       "cloudfront:GetInvalidation",
#       "cloudfront:ListInvalidations"
#     ]
#     resources = ["*"]
#   }
# }

# # BAD, DO NOT KEEP
# # variable "role_policy_docs" {
# #   type        = list(string)
# #   description = "Policies associated with Role"
# #   default     = [
# #     "data.aws_iam_policy_document.role_1.json",
# #     "data.aws_iam_policy_document.role_2.json",
# #   ]
# # }

# locals {
#   role_policies = [
#     data.aws_iam_policy_document.role_1.json,
#     data.aws_iam_policy_document.role_2.json,
#   ]
  

#   role_policy_docs = { 
#     for s in local.role_policies : 
#       index(local.role_policies, s) => s 
#     }
# }

# output "role_policy_docs" { value = local.role_policy_docs }

# resource "aws_iam_policy" "role" {
#   for_each = local.role_policy_docs

#   name        = format("RolePolicy-%02d", each.key)
#   description = "Custom Policies for Role"

#   policy = each.value
# }

# resource "aws_iam_role_policy_attachment" "role" {
#   for_each   = { for p in aws_iam_policy.role : p.name => p.arn }
#   role       = aws_iam_role.role.name
#   policy_arn = each.value
# }

# resource "aws_iam_role" "role" {
#   name = "test_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }
