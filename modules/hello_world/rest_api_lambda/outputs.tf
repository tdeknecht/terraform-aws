# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "rest_api_id" {
  description = "The ID of the REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "deployment_id" {
  description = "The ID of the deployment"
  value       = aws_api_gateway_deployment.deployment.id
}

output "deployment_stage_name" {
  description = "The name of the stage"
  value       = aws_api_gateway_deployment.deployment.stage_name
}

output "deployment_invoke_url" {
  description = "The URL to invoke the API pointing to the stage"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}

output "deployment_stage_arns" {
  description = "A list of additional deployment stage ARNs"
  value = length(var.stages) == 0 ? {} : {
    for stage in var.stages :
    stage => aws_api_gateway_stage.stage[stage].arn
  }
}