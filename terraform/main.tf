# ===========================
# DATABASE INFRASTRUCTURE
# ===========================

# Data sources para recursos existentes
data "aws_vpc" "existing" {
  default = true
}

# Subnets específicas para o RDS
data "aws_subnet" "fastfood_subnet_1a" {
  id = "subnet-08d34ed68511f3917"  # us-east-1a
}

data "aws_subnet" "fastfood_subnet_1b" {
  id = "subnet-07fe020cefc4bd241"  # us-east-1b
}

# Lista das subnets para o RDS
locals {
  rds_subnet_ids = [
    data.aws_subnet.fastfood_subnet_1a.id,  # us-east-1a
    data.aws_subnet.fastfood_subnet_1b.id,  # us-east-1b
  ]
}

# Data source para o security group do EKS (criado pelo repo K8s)
data "aws_security_groups" "eks_node_sg" {
  filter {
    name   = "tag:kubernetes.io/cluster/fast-food-cluster-prd"
    values = ["owned"]
  }
  filter {
    name   = "group-name"
    values = ["*node*"]
  }
}

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

# RDS MySQL Instance
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

  vpc_security_group_ids = [data.aws_security_groups.eks_node_sg.ids[0]]
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

# Security group rule para permitir MySQL do EKS
resource "aws_security_group_rule" "rds_mysql_access" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_groups.eks_node_sg.ids[0]
  security_group_id        = data.aws_security_groups.eks_node_sg.ids[0]
  description              = "MySQL access from EKS cluster"
}