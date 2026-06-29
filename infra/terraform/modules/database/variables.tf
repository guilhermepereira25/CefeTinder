variable "project_name" {
  description = "Nome do projeto associado ao banco."
  type        = string
}

variable "environment" {
  description = "Ambiente do banco provisionado."
  type        = string
}

variable "identifier" {
  description = "Identificador da instancia RDS simulada no Floci."
  type        = string
}

variable "engine_version" {
  description = "Versao do PostgreSQL usada pelo RDS simulado."
  type        = string
}

variable "instance_class" {
  description = "Classe da instancia RDS simulada."
  type        = string
}

variable "allocated_storage" {
  description = "Armazenamento alocado em GiB."
  type        = number
}

variable "database_name" {
  description = "Nome do banco de dados inicial."
  type        = string
}

variable "master_username" {
  description = "Usuario administrador do banco."
  type        = string
}

variable "master_password" {
  description = "Senha do usuario administrador do banco."
  type        = string
  sensitive   = true
}
