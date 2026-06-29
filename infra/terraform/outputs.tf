output "gateway_url" {
  description = "URL publica do API Gateway no ambiente configurado."
  value       = module.api_gateway.gateway_url
}

output "graphql_route" {
  description = "Endpoint publico da API GraphQL pelo gateway."
  value       = module.api_gateway.graphql_route
}

output "notification_route" {
  description = "Endpoint publico do Notification Service pelo gateway."
  value       = module.api_gateway.notification_route
}

output "database_identifier" {
  description = "Identificador da instancia RDS PostgreSQL simulada."
  value       = module.database.identifier
}

output "database_endpoint" {
  description = "Endpoint completo da instancia RDS PostgreSQL simulada."
  value       = module.database.endpoint
}

output "database_address" {
  description = "Endereco da instancia RDS PostgreSQL simulada."
  value       = module.database.address
}

output "database_port" {
  description = "Porta da instancia RDS PostgreSQL simulada."
  value       = module.database.port
}

output "database_name" {
  description = "Nome do banco PostgreSQL principal provisionado."
  value       = module.database.database_name
}

output "database_username" {
  description = "Usuario administrador do banco PostgreSQL provisionado."
  value       = module.database.username
}
