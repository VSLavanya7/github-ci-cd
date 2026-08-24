resource "aws_apigatewayv2_api" "wake" {
  name          = "${var.project_name}-wake"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "wake" {
  api_id             = aws_apigatewayv2_api.wake.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.wake.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "wake" {
  api_id             = aws_apigatewayv2_api.wake.id
  route_key          = "GET /wake"
  target             = "integrations/${aws_apigatewayv2_integration.wake.id}"
}

resource "aws_apigatewayv2_stage" "wake" {
  api_id      = aws_apigatewayv2_api.wake.id
  stage_name  = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wake.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.wake.execution_arn}/*/*"
}

output "wake_url" {
  value = "${aws_apigatewayv2_api.wake.api_endpoint}/prod/wake"
}