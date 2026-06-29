output "identifier" {
  description = "Identificador da instancia RDS."
  value       = aws_db_instance.postgres.identifier
}

output "address" {
  description = "Endereco do endpoint RDS."
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "Porta do endpoint RDS."
  value       = aws_db_instance.postgres.port
}

output "endpoint" {
  description = "Endpoint completo do RDS."
  value       = aws_db_instance.postgres.endpoint
}

output "database_name" {
  description = "Nome do banco criado."
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Usuario administrador do banco."
  value       = aws_db_instance.postgres.username
}
