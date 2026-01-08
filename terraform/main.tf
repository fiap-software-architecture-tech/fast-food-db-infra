# ===========================
# DATABASE INFRASTRUCTURE
# ===========================

# Data sources para recursos existentes
data "aws_vpc" "existing" {
  default = true
}

# Subnets específicas para o RDS
data "aws_subnet" "fastfood_subnet_1a" {
  id = "subnet-0f244c624d019846b"  # us-east-1a
}

data "aws_subnet" "fastfood_subnet_1b" {
  id = "subnet-02ec0d1778295e935"  # us-east-1b
}

# Lista das subnets para o RDS
locals {
  rds_subnet_ids = [
    data.aws_subnet.fastfood_subnet_1a.id,  # us-east-1a
    data.aws_subnet.fastfood_subnet_1b.id,  # us-east-1b
  ]
}

# ===========================
# SECURITY GROUPS
# ===========================

# Security Group para o EKS (será usado pelos nodes)
resource "aws_security_group" "eks_nodes" {
  name_prefix = "fastfood-eks-nodes-"
  vpc_id      = data.aws_vpc.existing.id
  description = "Security group para nodes do EKS FastFood"

  # Regras de entrada para comunicação interna
  ingress {
    description = "All traffic from same security group"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Regras de saída - permitir todo tráfego
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fastfood-eks-nodes-security-group"
    ManagedBy = "terraform"
    Component = "kubernetes"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group para o RDS
resource "aws_security_group" "rds_mysql" {
  name_prefix = "fastfood-rds-"
  vpc_id      = data.aws_vpc.existing.id
  description = "Security group para RDS MySQL FastFood"

  # Permitir acesso MySQL do EKS
  ingress {
    description     = "MySQL access from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Permitir acesso MySQL de toda a VPC (para troubleshooting)
  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  # Acesso específico para ranges comuns de pods EKS
  ingress {
    description = "MySQL access from EKS pod ranges"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",      # Range comum para pods
      "172.16.0.0/12",   # Range adicional
      "192.168.0.0/16"   # Range local
    ]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fastfood-rds-security-group"
    ManagedBy = "terraform"
    Component = "database"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regra adicional para garantir comunicação EKS -> RDS na porta 3306
resource "aws_security_group_rule" "eks_to_rds_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_mysql.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow EKS nodes to connect to RDS MySQL"
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
