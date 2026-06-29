resource "aws_db_instance" "postgres" {
  identifier                 = var.identifier
  engine                     = "postgres"
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  db_name                    = var.database_name
  username                   = var.master_username
  password                   = var.master_password
  auto_minor_version_upgrade = false
  skip_final_snapshot        = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
