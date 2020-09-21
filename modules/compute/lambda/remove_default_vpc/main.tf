# ------------------------------------------------------------------------------
# Lambda: Remove Default VPC
# ------------------------------------------------------------------------------

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/removeDefaultVpc.go"
  output_path = "${path.module}/removeDefaultVpc.zip"
}

# remove_default_vpc
resource "aws_lambda_function" "remove_default_vpc" {
  filename         = "${path.module}/remove_default_vpc.zip"
  function_name    = "remove_default_vpc"
  description      = "Remove the Default VPC in all AWS Regions"
  role             = aws_iam_role.remove_default_vpc_role.arn
  handler          = "remove_default_vpc.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = "go1.x"
  tags             = var.tags
}

resource "aws_lambda_alias" "remove_default_vpc_alias" {
  name             = "${var.ou}_v1"
  function_name    = aws_lambda_function.remove_default_vpc.arn
  function_version = aws_lambda_function.remove_default_vpc.version
}

# ------------------------------------------------------------------------------
# IAM: Policy document, role
# ------------------------------------------------------------------------------

# policy doc
data "aws_iam_policy_document" "remove_default_vpc_policy" {
  statement {
    sid    = "removeDefaultVpcRole"
    effect = "Allow"
    actions = [
      "ec2:*",
    ]
    resources = ["*"]
  }
}

# role
resource "aws_iam_role" "remove_default_vpc_role" {
  name               = "removeDefaultVpcRole"
  assume_role_policy = data.aws_iam_policy_document.remove_default_vpc_policy.json
}