# ===========================
# RDS MAIN DATABASE
# ===========================

# RDS MySQL Instance - Main FastFood Database
resource "aws_db_instance" "fastfood_mysql" {
  identifier = "fastfood-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type     = "gp2"
  storage_encrypted = var.db_storage_encrypted

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  vpc_security_group_ids = [aws_security_group.rds_mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.fastfood_mysql.name

  # RDS privado - apenas acessível dentro da VPC
  publicly_accessible    = false

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  auto_minor_version_upgrade = var.db_auto_minor_version_upgrade

  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot

  tags = {
    Name = "fastfood-rds"
    ManagedBy = "terraform"
    Component = "database"
    Environment = var.environment
  }
}