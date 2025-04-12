data "aws_lambda_function" "function" {
  for_each = var.functions
  function_name = each.key
}

resource "aws_lambda_function_event_invoke_config" "async_config" {
  for_each = var.functions

  function_name = data.aws_lambda_function.function[each.key].function_name
  maximum_event_age_in_seconds = each.value.maximum_event_age_in_seconds
  maximum_retry_attempts = each.value.maximum_retry_attempts
}

resource "aws_lambda_permission" "allow_api_gateway" {
  for_each = { for k, v in var.functions : k => v if v.allow_api_gateway && var.api_gateway_execution_arn != "" }

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.function[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = var.functions

  name              = "/aws/lambda/${data.aws_lambda_function.function[each.key].function_name}"
  retention_in_days = each.value.log_retention_days
}
