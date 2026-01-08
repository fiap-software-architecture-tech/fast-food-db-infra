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