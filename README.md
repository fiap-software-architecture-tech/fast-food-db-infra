# FastFood DB Infrastructure - Infraestrutura de Banco de Dados

![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4)
![AWS RDS](https://img.shields.io/badge/AWS-RDS-527FFF)
![DynamoDB](https://img.shields.io/badge/AWS-DynamoDB-4053D6)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1)

## 📋 Sobre o Repositório

Repositório de infraestrutura como código (IaC) responsável pelo provisionamento e gerenciamento de todos os recursos de banco de dados do sistema FastFood na AWS.

## 🎯 Responsabilidades

### Provisionamento de Bancos de Dados
- **RDS MySQL Main**: Banco principal para aplicação fast-food (clientes, produtos, categorias)
- **RDS MySQL Order**: Banco dedicado para microsserviço de pedidos
- **RDS MySQL Payment**: Banco dedicado para microsserviço de pagamentos
- **DynamoDB CTO**: Tabela NoSQL para microsserviço de cozinha (cook-to-order)

### Configurações de Rede e Segurança
- **VPC e Subnets**: Configuração de rede isolada
- **Security Groups**: Regras de firewall para acesso aos bancos
- **DB Subnet Groups**: Grupos de subnets para alta disponibilidade
- **Private Access**: Bancos acessíveis apenas dentro da VPC

### Gerenciamento
- **Backups Automáticos**: Configuração de retenção de backups
- **Multi-AZ**: Alta disponibilidade com réplicas em múltiplas zonas
- **Monitoring**: Integração com CloudWatch
- **Encryption**: Criptografia de dados em repouso

## 🏗️ Arquitetura

### Estrutura do Repositório

```
terraform/
├── data-sources.tf          → Data sources AWS (VPC, Subnets)
├── dynamodb-CTO.tf          → DynamoDB para Cook-to-Order
├── outputs.tf               → Outputs dos recursos criados
├── providers.tf             → Configuração de providers AWS
├── rds-main.tf              → RDS MySQL principal
├── rds-order.tf             → RDS MySQL para pedidos
├── rds-payment.tf           → RDS MySQL para pagamentos
├── rds-subnet-group.tf      → Subnet groups para RDS
├── security-groups.tf       → Security groups
├── variables.tf             → Variáveis de configuração
└── terraform.tfvars.example → Exemplo de variáveis
```

### Diagrama de Infraestrutura

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS VPC                              │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Subnet A   │  │   Subnet B   │  │   Subnet C   │     │
│  │  us-east-1a  │  │  us-east-1b  │  │  us-east-1c  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
│  ┌──────▼─────────────────▼─────────────────▼──────┐      │
│  │           DB Subnet Group                        │      │
│  └──────┬───────────┬───────────┬───────────────────┘      │
│         │           │           │                          │
│  ┌──────▼──────┐ ┌──▼───────┐ ┌▼────────────┐            │
│  │  RDS Main   │ │ RDS Order│ │ RDS Payment │            │
│  │   MySQL     │ │  MySQL   │ │   MySQL     │            │
│  │ (Multi-AZ)  │ │(Multi-AZ)│ │ (Multi-AZ)  │            │
│  └─────────────┘ └──────────┘ └─────────────┘            │
│                                                            │
│  ┌─────────────────────────────────────────┐              │
│  │         DynamoDB (Global)               │              │
│  │   fastfood-orders-cook-to-order         │              │
│  └─────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Stack Tecnológica

### Infrastructure as Code
- **Terraform**: >= 1.0
- **AWS Provider**: ~> 5.0

### AWS Services
- **Amazon RDS MySQL**: 8.0
  - Instance Class: db.t3.micro (configurável)
  - Storage: 20GB gp2 (configurável)
  - Multi-AZ: Habilitado
  - Backup Retention: 7 dias

- **Amazon DynamoDB**
  - Billing Mode: PAY_PER_REQUEST
  - Encryption: Habilitada
  - Point-in-time Recovery: Habilitado

### Recursos Provisionados

#### RDS Instances
1. **fastfood-db** (Main)
   - Database: `fastfood`
   - Uso: Aplicação principal (clientes, produtos, categorias)

2. **fastfood-order-db**
   - Database: `fastfood_order`
   - Uso: Microsserviço de pedidos

3. **fastfood-payment-db**
   - Database: `fastfood_payment`
   - Uso: Microsserviço de pagamentos

#### DynamoDB Tables
1. **fastfood-orders-cook-to-order**
   - Partition Key: `order_id` (String)
   - Uso: Fila de preparação da cozinha

## 🚀 Como Usar

### Pré-requisitos
- Terraform >= 1.0 instalado
- AWS CLI configurado com credenciais válidas
- Permissões IAM necessárias:
  - `AmazonRDSFullAccess`
  - `AmazonDynamoDBFullAccess`
  - `AmazonVPCFullAccess`

### Configuração

```bash
# 1. Clonar repositório
git clone https://github.com/fiap-software-architecture-tech/fast-food-db-infra.git
cd fast-food-db-infra/terraform

# 2. Copiar e configurar variáveis
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com suas configurações

# 3. Inicializar Terraform
terraform init

# 4. Validar configuração
terraform validate

# 5. Planejar mudanças
terraform plan

# 6. Aplicar infraestrutura
terraform apply
```

### Variáveis Importantes

```hcl
# terraform.tfvars
environment           = "production"
db_instance_class     = "db.t3.micro"
db_allocated_storage  = 20
db_username          = "admin"
db_password          = "SecurePassword123!"  # Use AWS Secrets Manager
db_multi_az          = true
db_backup_retention_period = 7
db_deletion_protection = true
db_skip_final_snapshot = false
```

### Outputs

Após o apply, os seguintes outputs estarão disponíveis:

```bash
# Endpoints RDS
rds_main_endpoint     = "fastfood-db.xxxxx.us-east-1.rds.amazonaws.com:3306"
rds_order_endpoint    = "fastfood-order-db.xxxxx.us-east-1.rds.amazonaws.com:3306"
rds_payment_endpoint  = "fastfood-payment-db.xxxxx.us-east-1.rds.amazonaws.com:3306"

# DynamoDB
dynamodb_table_name   = "fastfood-orders-cook-to-order"
dynamodb_table_arn    = "arn:aws:dynamodb:us-east-1:xxxxx:table/fastfood-orders-cook-to-order"
```

## 🔒 Segurança

### Boas Práticas Implementadas
- ✅ **Encryption at Rest**: Todos os bancos com criptografia habilitada
- ✅ **Private Subnets**: RDS em subnets privadas (sem acesso público)
- ✅ **Security Groups**: Acesso restrito apenas de recursos autorizados
- ✅ **Backup Automático**: Retenção de 7 dias configurável
- ✅ **Multi-AZ**: Alta disponibilidade em múltiplas zonas
- ✅ **Deletion Protection**: Proteção contra exclusão acidental
- ✅ **IAM Authentication**: Suporte a autenticação via IAM (configurável)

### Recomendações
- Use **AWS Secrets Manager** para armazenar credenciais
- Configure **VPN ou AWS PrivateLink** para acesso seguro
- Habilite **CloudWatch Alarms** para monitoramento
- Implemente **Backup Strategy** com snapshots manuais periódicos

## 📊 Monitoramento

### CloudWatch Metrics
- CPU Utilization
- Database Connections
- Free Storage Space
- Read/Write IOPS
- Read/Write Latency

### Logs
- Error Logs
- Slow Query Logs
- General Logs

## 💰 Estimativa de Custos

### RDS MySQL (por instância)
- **db.t3.micro**: ~$15-30/mês
- **Storage (20GB)**: ~$2-4/mês
- **Backup Storage**: Variável

### DynamoDB
- **On-Demand**: ~$0-10/mês (baseado em uso)

**Total Estimado**: ~$50-100/mês (3 RDS + 1 DynamoDB)

### Otimização de Custos
- Use instâncias menores em ambientes de desenvolvimento
- Configure `db_deletion_protection = false` em dev
- Use `db_skip_final_snapshot = true` em dev
- Considere Reserved Instances para produção

## 🔗 Repositórios Relacionados

- **[fast-food](https://github.com/fiap-software-architecture-tech/fast-food)** - Aplicação Principal
- **[fast-food-order](https://github.com/fiap-software-architecture-tech/fast-food-order)** - Microsserviço de Pedidos
- **[fast-food-payment](https://github.com/fiap-software-architecture-tech/fast-food-payment)** - Microsserviço de Pagamentos
- **[fast-food-cook-to-order](https://github.com/fiap-software-architecture-tech/fast-food-cook-to-order)** - Microsserviço de Cozinha
- **[fast-food-k8s-infra](https://github.com/fiap-software-architecture-tech/fast-food-k8s-infra)** - Infraestrutura Kubernetes

## 🧹 Cleanup

### Destruir Infraestrutura

```bash
# ATENÇÃO: Isso removerá todos os bancos de dados!
cd terraform
terraform destroy

# Para ambientes de produção, considere:
# 1. Fazer backup manual antes
# 2. Exportar dados importantes
# 3. Desabilitar deletion_protection se necessário
```

## 👥 Equipe

**Grupo 277 - SOAT FIAP**

- Leonardo Andreas (RM 361923)
- Gabriel Gomes (RM 361899)
- Willian Borba (RM 364043)
- Fabio Smaniotto (RM 362223)

## 📄 Licença

Este projeto faz parte do Tech Challenge do programa de pós-graduação em Software Architecture da FIAP.
