# ------------------------------------------------------------------------------
# Data
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

# ------------------------------------------------------------------------------
# Lambda: Remove Default VPC
# ------------------------------------------------------------------------------

# NOTE: archive_file resource is causing permissions errors where, depending on where this runs, the permissions
#       will not transfer (i.e. executable is either there or it isn't). Manually zipping for the time being.
#       https://github.com/hashicorp/terraform-provider-archive/issues/10

# data "archive_file" "lambda_function" {
#   type        = "zip"

#   source_dir  = "${path.module}/bin"
#   output_path = "${path.module}/main.zip"
# }

# remove_default_vpc
resource "aws_lambda_function" "remove_default_vpc" {
  filename         = "${path.module}/main.zip"
  function_name    = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-remove-default-vpc"
  description      = "Remove the Default VPC in all AWS Regions"
  role             = aws_iam_role.remove_default_vpc_role.arn # ec2 AssumeRole policy
  handler          = "bin/main"
  # source_code_hash = data.archive_file.lambda_function.output_base64sha256
  source_code_hash = filebase64sha256("${path.module}/bin/main.zip")
  runtime          = "go1.x"
  timeout          = "30"
  tags             = var.tags
}

resource "aws_lambda_alias" "remove_default_vpc_alias" {
  name             = "${var.ou}_v1"
  function_name    = aws_lambda_function.remove_default_vpc.arn
  function_version = aws_lambda_function.remove_default_vpc.version
}

# ------------------------------------------------------------------------------
# IAM: Policy document, policy, attachment, role
# ------------------------------------------------------------------------------

# assumerole policy doc
data "aws_iam_policy_document" "remove_default_vpc_assumerole" {
  statement {
    sid     = "removeDefaultVpcAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# lambda role policy doc
data "aws_iam_policy_document" "remove_default_vpc" {
  statement {
    sid    = "removeDefaultVpcPolicy"
    effect = "Allow"
    actions = [
      "ec2:*",
    ]
    resources = ["*"]
  }
}

# lambda role policy
resource "aws_iam_policy" "remove_default_vpc" {
  name        = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-remove-default-vpc-policy"
  description = "Remove Default VPC policy"
  policy      = data.aws_iam_policy_document.remove_default_vpc.json
}

# lambda role
resource "aws_iam_role" "remove_default_vpc_role" {
  name               = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-remove-default-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.remove_default_vpc_assumerole.json
}

# lambda role policy attachment
resource "aws_iam_role_policy_attachment" "remove_default_vpc_policy_attachment" {
  role       = aws_iam_role.remove_default_vpc_role.name
  policy_arn = aws_iam_policy.remove_default_vpc.arn
}

# lambdaBasicsExecutionRole policy attachment (allows writing to CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachment" {
  role       = aws_iam_role.remove_default_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ------------------------------------------------------------------------------
# CloudWatch: log group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "remove_default_vpc" {
  name              = "/aws/lambda/${var.ou}-${data.aws_iam_account_alias.current.account_alias}-remove-default-vpc"
  retention_in_days = 7
  tags              = var.tags
}