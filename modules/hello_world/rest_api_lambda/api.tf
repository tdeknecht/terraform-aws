# ------------------------------------------------------------------------------
# Data and Locals
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_account_alias" "current" {}

# ------------------------------------------------------------------------------
# API Gateway: API
# ------------------------------------------------------------------------------

data "aws_vpc_endpoint" "execute_api" {
  count  = length(var.vpc_endpoint_ids) > 0 ? 1 : 0

  filter {
    name = "vpc-endpoint-id"
    values = var.vpc_endpoint_ids
  }
}

data "aws_iam_policy_document" "private_api" {
  count  = length(var.vpc_endpoint_ids) > 0 ? 1 : 0

  statement {
    sid       = "invokeApi"
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["execute-api:/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
  statement {
    sid       = "invokeApi"
    effect    = "Deny"
    actions   = ["execute-api:Invoke"]
    resources = ["execute-api:/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test = "StringNotEquals"
      variable = "aws:SourceVpc"
      values = [data.aws_vpc_endpoint.execute_api[0].vpc_id]
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-${var.name}-${var.type}-api"
  description = "A ${var.type} Hello World API with Lambda integration"
  tags        = var.tags

  endpoint_configuration {
    types = [var.type]
    vpc_endpoint_ids = length(var.vpc_endpoint_ids) > 0 ? var.vpc_endpoint_ids : null
  }
  policy = length(var.vpc_endpoint_ids) > 0 ? data.aws_iam_policy_document.private_api[0].json : null

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.api.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.hello_world.invoke_arn
}

# the proxy resource cannot match an empty path at the root of the API. To handle that, a similar 
# configuration must be applied to the root resource that is built in to the REST API object
resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.api.id
   resource_id   = aws_api_gateway_rest_api.api.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.hello_world.invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "default"

  # redeploy if code changes
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.lambda),
      jsonencode(aws_api_gateway_integration.lambda_root),
    )))
    # redeployment = sha1(file("main.tf"))
  }

  # reduce downtime by recreating before destroying
  lifecycle {
    create_before_destroy = true
  }
}

# Additional deployment stages
resource "aws_api_gateway_stage" "stage" {
  for_each = var.stages

  stage_name    = each.value
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}