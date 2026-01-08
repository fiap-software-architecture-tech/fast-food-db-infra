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

# ===========================
# SECURITY GROUPS OUTPUTS
# ===========================

output "rds_security_group_id" {
  description = "Security Group ID usado pelo RDS"
  value       = aws_security_group.rds_mysql.id
}

output "eks_nodes_security_group_id" {
  description = "Security Group ID para os nodes do EKS"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_arn" {
  description = "ARN do security group do RDS"
  value       = aws_security_group.rds_mysql.arn
}

output "eks_nodes_security_group_arn" {
  description = "ARN do security group dos nodes EKS"
  value       = aws_security_group.eks_nodes.arn
}

# ===========================
# DYNAMODB OUTPUTS
# ===========================

output "dynamodb_cook_to_order_table_name" {
  description = "Nome da tabela DynamoDB para cook-to-order"
  value       = aws_dynamodb_table.orders_cook_to_order.name
}

output "dynamodb_cook_to_order_table_arn" {
  description = "ARN da tabela DynamoDB para cook-to-order"
  value       = aws_dynamodb_table.orders_cook_to_order.arn
}

output "dynamodb_cook_to_order_table_id" {
  description = "ID da tabela DynamoDB para cook-to-order"
  value       = aws_dynamodb_table.orders_cook_to_order.id
}

output "dynamodb_cook_to_order_hash_key" {
  description = "Hash key da tabela DynamoDB cook-to-order"
  value       = aws_dynamodb_table.orders_cook_to_order.hash_key
}
