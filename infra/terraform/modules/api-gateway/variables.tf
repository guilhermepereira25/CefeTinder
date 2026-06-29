variable "project_name" {
  description = "Nome do projeto usado no API Gateway."
  type        = string
}

variable "environment" {
  description = "Nome do stage do API Gateway."
  type        = string
}

variable "graphql_api_url" {
  description = "URL base para encaminhar requisicoes /graphql."
  type        = string
}

variable "notification_api_url" {
  description = "URL base para encaminhar requisicoes /notifications."
  type        = string
}
