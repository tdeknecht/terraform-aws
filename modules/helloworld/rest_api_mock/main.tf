# ------------------------------------------------------------------------------
# Data and Locals
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_account_alias" "current" {}

locals {
  endpoint_configuration_no_vpc = length(var.vpc_endpoint_ids) == 0 ? toset([var.type]) : toset([])

  endpoint_configuration_vpc = length(var.vpc_endpoint_ids) > 0 ? {
    (var.type) = var.vpc_endpoint_ids
  } : {}
}

# ------------------------------------------------------------------------------
# API Gateway: API
# ------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.ou}-${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-${var.name}-${var.type}-api"
  description = "A ${var.type} Hello World API with MOCK integration"
  tags        = var.tags

  dynamic "endpoint_configuration" {
    for_each = local.endpoint_configuration_no_vpc

    content {
      types = [upper(endpoint_configuration.value)]
    }
  }

  dynamic "endpoint_configuration" {
    for_each = local.endpoint_configuration_vpc

    content {
      types            = [upper(endpoint_configuration.key)]
      vpc_endpoint_ids = endpoint_configuration.value
    }
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "base"
}

# GET method
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.parm" = true,
  }
}

resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "get_500" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "500"
}

# GET integration
resource "aws_api_gateway_integration" "get" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.resource.id
  http_method          = aws_api_gateway_method.get.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
{
    #if( $input.params('parm') == "value" )
      "statusCode": 200
    #else
      "statusCode": 500
    #end
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "get_200" {
  depends_on = [aws_api_gateway_integration.get]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_200.status_code

  response_templates = {
    "application/json" = <<EOF
{
    "statusCode": 200,
    "name" : "Hello World"
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "get_500" {
  depends_on = [aws_api_gateway_integration.get]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "500"
  # status_code = aws_api_gateway_method_response.get_500.status_code

  selection_pattern = "5\\d{2}"
  response_templates = {
    "application/json" = <<EOF
{
    "statusCode": 500,
    "name": "Error"
}
EOF
  }
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.get]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "default"

  # redeploy if code changes
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.get),
    )))
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
}