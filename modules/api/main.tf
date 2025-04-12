resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "API Gateway for AJF Live Re-wire project"

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "rewire_lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.rewire_lambda_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "oz_rewire_lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.oz_rewire_lambda_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "rewire_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /${var.rewire_route_path}"
  target    = "integrations/${aws_apigatewayv2_integration.rewire_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "oz_rewire_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /${var.oz_rewire_route_path}"
  target    = "integrations/${aws_apigatewayv2_integration.oz_rewire_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}
