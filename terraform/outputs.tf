# ===========================
# DATABASE OUTPUTS
# ===========================

output "rds_endpoint" {
  description = "Endpoint do RDS MySQL"
  value       = aws_db_instance.fastfood_mysql.endpoint
}

output "rds_address" {
  description = "Address do RDS MySQL (sem porta)"
  value       = aws_db_instance.fastfood_mysql.address
}

output "rds_database_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.fastfood_mysql.db_name
}

output "rds_username" {
  description = "Username do banco de dados"
  value       = aws_db_instance.fastfood_mysql.username
  sensitive   = true
}

output "rds_port" {
  description = "Porta do banco de dados"
  value       = aws_db_instance.fastfood_mysql.port
}

output "database_url" {
  description = "URL completa de conexão do banco"
  value       = "mysql://:@/?allowPublicKeyRetrieval=true"
  sensitive   = true
}

output "vpc_id" {
  description = "ID da VPC"
  value       = data.aws_vpc.existing.id
}

output "rds_subnet_group_name" {
  description = "Nome do subnet group do RDS"
  value       = aws_db_subnet_group.fastfood_mysql.name
}

output "rds_security_group_id" {
  description = "Security Group ID usado pelo RDS"
  value       = aws_security_group.rds_mysql.id
}
