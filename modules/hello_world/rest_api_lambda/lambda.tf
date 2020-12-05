# ------------------------------------------------------------------------------
# Lambda: Hello World
# ------------------------------------------------------------------------------
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/hello_world.py"
  output_path = "${path.module}/hello_world.zip"
}

# manual approach
# zip hello_world.zip hello_world.py
# aws s3 cp hello_world.zip s3://td000/lambdas/python3/hello_world/v1.0.0/hello_world.zip

# hello_world
resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-py3"
  description      = "A simple Lambda using Python 3"
  role             = aws_iam_role.hello_world_role.arn # ec2 AssumeRole policy
  handler          = "hello_world.lambda_handler"
  filename         = "${path.module}/hello_world.zip"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256 # if using archive_file approach
  # source_code_hash = filebase64sha256("${path.module}/hello_world.zip") # if zipped locally and not put in S3
  # s3_bucket        = "td000"
  # s3_key           = "lambdas/python3/hello_world/v1.0.0/hello_world.zip"
  runtime          = "python3.8"
  timeout          = "5"
  tags             = var.tags
}

resource "aws_lambda_alias" "hello_world_alias" {
  name             = "${var.ou}_v1"
  function_name    = aws_lambda_function.hello_world.arn
  function_version = aws_lambda_function.hello_world.version
}

# ------------------------------------------------------------------------------
# IAM: Policy document, policy, attachment, role
# ------------------------------------------------------------------------------

# assumerole policy doc
data "aws_iam_policy_document" "hello_world_assumerole" {
  statement {
    sid     = "helloWorldLambdaPythonAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# lambda role
resource "aws_iam_role" "hello_world_role" {
  name               = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-py3-role"
  assume_role_policy = data.aws_iam_policy_document.hello_world_assumerole.json
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "allowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.hello_world.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# lambdaBasicsExecutionRole policy attachment (allows writing to CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachment" {
  role       = aws_iam_role.hello_world_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ------------------------------------------------------------------------------
# CloudWatch: log group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/aws/lambda/${var.ou}-${data.aws_iam_account_alias.current.account_alias}-hello-world-py3"
  retention_in_days = 7
  tags              = var.tags
}