# ------------------------------------------------------------------------------
# Data
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

# ------------------------------------------------------------------------------
# Lambda: Hello World Go
# ------------------------------------------------------------------------------

# NOTE: archive_file resource is causing permissions errors where, depending on where this runs, the permissions
#       will not transfer (i.e. executable is either there or it isn't). Manually zipping for the time being.
#       https://github.com/hashicorp/terraform-provider-archive/issues/10

# data "archive_file" "lambda_function" {
#   type        = "zip"

#   source_dir  = "${path.module}/bin"
#   output_path = "${path.module}/main.zip"
# }

# hello_world_go
resource "aws_lambda_function" "hello_world_go" {
  filename         = "${path.module}/bin/main.zip"
  function_name    = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-go"
  description      = "A simple Lambda using Go"
  role             = aws_iam_role.hello_world_go_role.arn # ec2 AssumeRole policy
  handler          = "bin/main"
  # source_code_hash = data.archive_file.lambda_function.output_base64sha256
  source_code_hash = filebase64sha256("${path.module}/bin/main.zip")
  runtime          = "go1.x"
  timeout          = "5"
  tags             = var.tags
}

resource "aws_lambda_alias" "hello_world_go_alias" {
  name             = "${var.ou}_v1"
  function_name    = aws_lambda_function.hello_world_go.arn
  function_version = aws_lambda_function.hello_world_go.version
}

# ------------------------------------------------------------------------------
# IAM: Policy document, policy, attachment, role
# ------------------------------------------------------------------------------

# assumerole policy doc
data "aws_iam_policy_document" "hello_world_go_assumerole" {
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
data "aws_iam_policy_document" "hello_world_go" {
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
resource "aws_iam_policy" "hello_world_go" {
  name        = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-go-policy"
  description = "Hello World Go policy"
  policy      = data.aws_iam_policy_document.hello_world_go.json
}

# lambda role
resource "aws_iam_role" "hello_world_go_role" {
  name               = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-go-role"
  assume_role_policy = data.aws_iam_policy_document.hello_world_go_assumerole.json
}

# lambda role policy attachment
resource "aws_iam_role_policy_attachment" "hello_world_go_policy_attachment" {
  role       = aws_iam_role.hello_world_go_role.name
  policy_arn = aws_iam_policy.hello_world_go.arn
}

# lambdaBasicsExecutionRole policy attachment (allows writing to CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachment" {
  role       = aws_iam_role.hello_world_go_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ------------------------------------------------------------------------------
# CloudWatch: log group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "hello_world_go" {
  name              = "/aws/lambda/${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-go"
  retention_in_days = 7
  tags              = var.tags
}