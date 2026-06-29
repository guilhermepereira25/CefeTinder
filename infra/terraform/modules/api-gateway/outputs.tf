output "gateway_url" {
  description = "URL publica do stage do API Gateway."
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "graphql_route" {
  description = "Endpoint publico da API GraphQL."
  value       = "${aws_apigatewayv2_stage.this.invoke_url}/graphql"
}

output "notification_route" {
  description = "Endpoint publico do Notification Service."
  value       = "${aws_apigatewayv2_stage.this.invoke_url}/notifications"
}
