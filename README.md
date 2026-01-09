# FastFood Database Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-1.5.0-7B42BC)
![AWS RDS](https://img.shields.io/badge/AWS-RDS-FF9900)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1)
![DynamoDB](https://img.shields.io/badge/DynamoDB-NoSQL-4053D6)

## 📋 Sobre

Este repositório contém a infraestrutura de banco de dados para o projeto FastFood, implementando uma arquitetura de microsserviços com **isolamento completo de dados**. Cada microsserviço possui seu próprio banco de dados dedicado, seguindo as melhores práticas de arquitetura de microsserviços.

## 🎯 Arquitetura de Dados

### Estratégia de Banco de Dados por Microsserviço

Seguindo o princípio de **Database per Service**, cada microsserviço possui seu próprio banco de dados:

```
┌─────────────────┐     ┌──────────────────┐
│  fast-food      │────▶│ MySQL RDS        │
│  (Main App)     │     │ fastfood_main    │
└─────────────────┘     └──────────────────┘

┌─────────────────┐     ┌──────────────────┐
│  fast-food-auth │────▶│ MySQL RDS        │
│  (Auth)         │     │ fastfood_main    │
└─────────────────┘     └──────────────────┘

┌─────────────────┐     ┌──────────────────┐
│  fast-food-order│────▶│ MySQL RDS        │
│  (Orders)       │     │ fastfood_order   │
└─────────────────┘     └──────────────────┘

┌─────────────────┐     ┌──────────────────┐
│fast-food-payment│────▶│ MySQL RDS        │
│  (Payments)     │     │ fastfood_payment │
└─────────────────┘     └──────────────────┘

┌─────────────────┐     ┌──────────────────┐
│fast-food-cook-  │────▶│ DynamoDB         │
│  to-order (CTO) │     │ orders-cto       │
└─────────────────┘     └──────────────────┘
```

## 🗄️ Bancos de Dados Implementados

### SQL (MySQL 8.0 - Amazon RDS)

#### 1. **fastfood_main** (Compartilhado: Main App + Auth)
- **Serviços**: `fast-food` + `fast-food-auth`
- **Motivo do compartilhamento**: Auth e Main App compartilham entidades de Cliente
- **Tabelas**:
  - `clients` - Dados de clientes
  - `products` - Catálogo de produtos
  - `categories` - Categorias de produtos
- **Características**:
  - Engine: MySQL 8.0
  - Instance: db.t3.micro
  - Storage: 20GB GP2
  - Multi-AZ: Configurável
  - Backup: 7 dias de retenção

#### 2. **fastfood_order** (Dedicado: Order Service)
- **Serviço**: `fast-food-order`
- **Tabelas**:
  - `orders` - Pedidos
  - `order_products` - Itens do pedido
- **Características**:
  - Engine: MySQL 8.0
  - Instance: db.t3.micro
  - Storage: 20GB GP2
  - Isolamento completo de dados de pedidos

#### 3. **fastfood_payment** (Dedicado: Payment Service)
- **Serviço**: `fast-food-payment`
- **Tabelas**:
  - `payments` - Transações de pagamento
  - `payment_logs` - Histórico de webhooks
- **Características**:
  - Engine: MySQL 8.0
  - Instance: db.t3.micro
  - Storage: 20GB GP2
  - Isolamento completo de dados financeiros

### NoSQL (DynamoDB)

#### 4. **fastfood-orders-cook-to-order** (Dedicado: CTO Service)
- **Serviço**: `fast-food-cook-to-order`
- **Partition Key**: `order_id` (String)
- **Billing Mode**: PAY_PER_REQUEST (On-Demand)
- **Motivo da escolha NoSQL**:
  - ✅ **Alta Performance**: Latência de milissegundos
  - ✅ **Escalabilidade Automática**: Ajusta capacidade conforme demanda
  - ✅ **Operações Simples**: CRUD por ID, sem JOINs complexos
  - ✅ **Real-time**: Ideal para atualizações frequentes de status
  - ✅ **Custo-benefício**: Pay-per-request para workloads variáveis

**Estrutura de Dados**:
```json
{
  "order_id": "uuid",
  "order_number": 123,
  "status": "PREPARING",
  "items": [...],
  "priority": 1,
  "created_at": "2026-01-09T19:00:00Z",
  "updated_at": "2026-01-09T19:05:00Z"
}
```

## 🏗️ Estrutura do Repositório

```
fast-food-db-infra/
├── terraform/
│   ├── providers.tf           → Configuração AWS
│   ├── variables.tf           → Variáveis de configuração
│   ├── data-sources.tf        → VPC e Subnets
│   ├── security-groups.tf     → Security Groups RDS
│   ├── rds-subnet-group.tf    → Subnet Group para RDS
│   ├── rds-main.tf            → RDS Main (App + Auth)
│   ├── rds-order.tf           → RDS Order Service
│   ├── rds-payment.tf         → RDS Payment Service
│   ├── dynamodb-CTO.tf        → DynamoDB Cook-to-Order
│   └── outputs.tf             → Outputs de conexão
└── .github/workflows/
    └── terraform-deploy.yml   → CI/CD Terraform
```

## 🔒 Segurança e Isolamento

### Isolamento de Rede
- **RDS Instances**: Privadas (não acessíveis publicamente)
- **VPC**: Todas as instâncias na mesma VPC
- **Security Groups**: Regras específicas por serviço
- **Acesso**: Apenas via Lambda/EKS dentro da VPC

### Isolamento de Dados
- ✅ Cada microsserviço acessa **APENAS** seu próprio banco
- ✅ Sem acesso cross-database
- ✅ Credenciais isoladas por serviço
- ✅ Comunicação entre serviços via API (não via DB)

### Credenciais
- Armazenadas em **AWS Secrets Manager** ou **Environment Variables**
- Rotação automática configurável
- Acesso via IAM Roles

## 🚀 Deploy

### Pré-requisitos
- Terraform 1.5.0+
- AWS CLI configurado
- Credenciais AWS com permissões para RDS e DynamoDB

### Variáveis Necessárias

```hcl
# terraform.tfvars
environment              = "production"
db_username             = "admin"
db_password             = "SECURE_PASSWORD"
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
db_multi_az             = false
db_backup_retention_period = 7
db_deletion_protection  = true
db_skip_final_snapshot  = false
```

### Comandos de Deploy

```bash
# Inicializar Terraform
cd terraform
terraform init

# Validar configuração
terraform validate

# Planejar mudanças
terraform plan

# Aplicar infraestrutura
terraform apply

# Outputs (endpoints de conexão)
terraform output
```

## 🔄 CI/CD

Este repositório possui workflow automatizado de CI/CD via GitHub Actions:

### Workflow: `terraform-deploy.yml`
- **Trigger**: Merge para `modulo_4`
- **Jobs**:
  - Validação Terraform
  - Plan (preview de mudanças)
  - Apply (deploy automático)
  - Outputs (endpoints de conexão)

## 📊 Monitoramento

### CloudWatch Metrics
- **RDS**:
  - CPU Utilization
  - Database Connections
  - Free Storage Space
  - Read/Write IOPS

- **DynamoDB**:
  - Consumed Read/Write Capacity
  - Throttled Requests
  - User Errors

### Logs
- RDS Error Logs → CloudWatch Logs
- DynamoDB Access Logs → CloudWatch Logs

## 🔗 Conexão dos Microsserviços

Cada microsserviço se conecta ao seu banco via:

### RDS (MySQL)
```typescript
// Prisma ORM
DATABASE_URL="mysql://user:pass@fastfood-order-db.xxx.rds.amazonaws.com:3306/fastfood_order"
```

### DynamoDB
```typescript
// AWS SDK
const dynamodb = new DynamoDBClient({
  region: "us-east-1"
});
```

## 👥 Equipe

**Grupo 277 - SOAT FIAP**

- Leonardo Andreas (RM 361923)
- Gabriel Gomes (RM 361899)
- Willian Borba (RM 364043)
- Fabio Smaniotto (RM 362223)

## 📄 Licença

Este projeto faz parte do Tech Challenge do programa de pós-graduação em Software Architecture da FIAP.
