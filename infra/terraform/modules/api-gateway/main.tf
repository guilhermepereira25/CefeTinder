locals {
  name = "${var.project_name}-${var.environment}-gateway"
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.name
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["accept", "authorization", "content-type", "origin", "x-requested-with"]
    allow_methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "graphql" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.graphql_api_url
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "notification" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.notification_api_url
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "graphql_root" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /graphql"
  target    = "integrations/${aws_apigatewayv2_integration.graphql.id}"
}

resource "aws_apigatewayv2_route" "graphql_proxy" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /graphql/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.graphql.id}"
}

resource "aws_apigatewayv2_route" "notification_root" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /notifications"
  target    = "integrations/${aws_apigatewayv2_integration.notification.id}"
}

resource "aws_apigatewayv2_route" "notification_proxy" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /notifications/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.notification.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true
}
