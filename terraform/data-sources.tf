# ===========================
# DATA SOURCES & LOCALS
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