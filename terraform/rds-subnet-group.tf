# ===========================
# RDS SUBNET GROUP
# ===========================

# Subnet group para o RDS
resource "aws_db_subnet_group" "fastfood_mysql" {
  name       = "fastfood-db-subnet-group"
  subnet_ids = local.rds_subnet_ids

  tags = {
    Name = "fastfood-db-subnet-group"
    ManagedBy = "terraform"
    Component = "database"
  }
}