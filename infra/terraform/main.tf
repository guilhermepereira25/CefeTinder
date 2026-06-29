module "api_gateway" {
  source = "./modules/api-gateway"

  project_name         = var.project_name
  environment          = var.environment
  graphql_api_url      = var.graphql_api_url
  notification_api_url = var.notification_api_url
}

module "database" {
  source = "./modules/database"

  project_name      = var.project_name
  environment       = var.environment
  identifier        = var.database_identifier
  engine_version    = var.database_engine_version
  instance_class    = var.database_instance_class
  allocated_storage = var.database_allocated_storage
  database_name     = var.database_name
  master_username   = var.database_master_username
  master_password   = var.database_master_password
}
