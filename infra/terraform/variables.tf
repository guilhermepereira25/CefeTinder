variable "project_name" {
  description = "Nome do projeto usado nos recursos provisionados."
  type        = string
  default     = "cefetinder"
}

variable "environment" {
  description = "Nome do ambiente publicado no API Gateway."
  type        = string
  default     = "homolog"
}

variable "aws_region" {
  description = "Regiao AWS usada pelo provider ou pelo endpoint Floci."
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "Access key usada pelo provider AWS/Floci."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret key usada pelo provider AWS/Floci."
  type        = string
  default     = "test"
  sensitive   = true
}

variable "floci_endpoint" {
  description = "Endpoint do servico API Gateway v2 no Floci."
  type        = string
  default     = "http://localhost:4566"
}

variable "graphql_api_url" {
  description = "URL base da API GraphQL, inicialmente publicada pela API 1 em EC2 ou equivalente."
  type        = string
  default     = "http://graphql-service:4000"
}

variable "notification_api_url" {
  description = "URL base do Notification Service, inicialmente publicada pela API 2 via Kubernetes Ingress."
  type        = string
  default     = "http://notification-service:8080"
}

variable "database_identifier" {
  description = "Identificador da instancia RDS PostgreSQL simulada no Floci."
  type        = string
  default     = "cefetinder-postgres"
}

variable "database_engine_version" {
  description = "Versao do PostgreSQL usada pelo RDS simulado no Floci."
  type        = string
  default     = "16.3"
}

variable "database_instance_class" {
  description = "Classe da instancia RDS simulada."
  type        = string
  default     = "db.t3.micro"
}

variable "database_allocated_storage" {
  description = "Armazenamento alocado em GiB para o RDS simulado."
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Nome do banco PostgreSQL principal do projeto."
  type        = string
  default     = "cefetinder"
}

variable "database_master_username" {
  description = "Usuario administrador do RDS PostgreSQL simulado."
  type        = string
  default     = "user"
}

variable "database_master_password" {
  description = "Senha do usuario administrador do RDS PostgreSQL simulado."
  type        = string
  default     = "secret123"
  sensitive   = true
}
