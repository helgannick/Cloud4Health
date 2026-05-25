# 🏥 Cloud4Health - Infraestrutura AWS com Terraform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow)

## 📋 Sobre o Projeto

**Projeto Integrado - Anhanguera**  
**Aluno:** Marcos Barbosa Carvalho dos Santos  
**Matrícula:** 2025154184  
**Disciplina:** Administração de Sistemas Operacionais

Este projeto implementa a modernização completa da infraestrutura da **Cloud4Health**, uma plataforma de tecnologia para clínicas médicas, migrando de uma arquitetura monolítica para uma solução moderna em nuvem AWS.

## 🎯 Objetivos

- ✅ Migração progressiva para nuvem AWS
- ✅ Implementação de containers com ECS Fargate
- ✅ Automação com Terraform (Infrastructure as Code)
- ✅ Arquitetura de rede moderna e segura
- ✅ Banco de dados otimizado com RDS
- ✅ Implementação de boas práticas de segurança
- ✅ Conformidade com AWS Well-Architected Framework

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────┐
│           Cloud4Health AWS Architecture          │
└─────────────────────────────────────────────────┘

VPC (10.0.0.0/16) - Multi-AZ
├── Public Subnets (2 AZs)
│   ├── Application Load Balancer
│   └── NAT Gateway
├── Private Subnets (2 AZs)
│   └── ECS Fargate Tasks
└── Database Subnets (2 AZs)
    └── RDS PostgreSQL (Multi-AZ)
```

## 📁 Estrutura do Projeto

```
cloud4health-terraform/
├── main.tf                  # Configuração principal
├── variables.tf             # Variáveis globais
├── outputs.tf              # Outputs globais
├── terraform.tfvars        # Valores das variáveis
├── README.md
├── .gitignore
│
├── modules/
│   ├── networking/         # ✅ FASE 1 - Concluída
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/           # 🔄 FASE 2 - Próxima
│   ├── compute/            # 🔄 FASE 3
│   ├── database/           # 🔄 FASE 4
│   ├── storage/            # 🔄 FASE 5
│   └── monitoring/         # 🔄 FASE 6
│
├── docker/                 # Aplicação containerizada
│   └── app/
└── scripts/               # Scripts auxiliares
```

## 🚀 Como Usar

### Pré-requisitos

- AWS CLI configurado
- Terraform >= 1.0
- Conta AWS (Free Tier recomendado)

### Passo 1: Inicializar Terraform

```bash
cd cloud4health-terraform
terraform init
```

### Passo 2: Validar Configuração

```bash
terraform validate
```

### Passo 3: Planejar Deployment

```bash
terraform plan
```

### Passo 4: Aplicar Infraestrutura

```bash
terraform apply
```

### Passo 5: Visualizar Outputs

```bash
terraform output
```

## 📊 Recursos Criados (Fase 1 - Networking)

- ✅ 1x VPC (10.0.0.0/16)
- ✅ 6x Subnets (2 públicas, 2 privadas, 2 database)
- ✅ 1x Internet Gateway
- ✅ 1x NAT Gateway (single para economia)
- ✅ 5x Route Tables
- ✅ 1x DB Subnet Group
- ✅ VPC Flow Logs (auditoria)

## 💰 Estimativa de Custos (Fase 1)

| Recurso | Custo Mensal | Free Tier |
|---------|--------------|-----------|
| VPC | Grátis | ✅ |
| Subnets | Grátis | ✅ |
| Internet Gateway | Grátis | ✅ |
| NAT Gateway | ~$32 | ❌ |
| VPC Flow Logs | ~$0.50 | Parcial |
| **TOTAL Fase 1** | **~$33/mês** | |

💡 **Dica:** Destrua recursos quando não estiver usando: `terraform destroy`

## 🔒 AWS Well-Architected Framework

### Pilares Implementados (Fase 1)

✅ **Excelência Operacional**
- Infrastructure as Code com Terraform
- Versionamento no Git
- Módulos reutilizáveis

✅ **Segurança**
- Isolamento de rede em camadas
- VPC Flow Logs para auditoria
- Subnets privadas sem acesso direto à Internet
- Database em subnet totalmente isolada

✅ **Confiabilidade**
- Multi-AZ deployment
- Redundância de subnets
- NAT Gateway para saída controlada

✅ **Eficiência de Performance**
- Arquitetura preparada para ECS Fargate
- Database subnet group para RDS otimizado

✅ **Otimização de Custos**
- Single NAT Gateway (economia)
- Uso de Free Tier
- Tags para cost allocation

✅ **Sustentabilidade**
- Recursos sob demanda
- Infraestrutura destruível

## 📈 Próximas Fases

- [ ] **Fase 2:** Security (Security Groups, IAM Roles)
- [ ] **Fase 3:** Compute (ECS Fargate, ALB, Auto Scaling)
- [ ] **Fase 4:** Database (RDS PostgreSQL, índices otimizados)
- [ ] **Fase 5:** Storage (S3 Buckets, Lifecycle Policies)
- [ ] **Fase 6:** Monitoring (CloudWatch, Alarms, Dashboards)
- [ ] **Fase 7:** Application (FastAPI containerizada)

## 🔧 Comandos Úteis

```bash
# Formatar código Terraform
terraform fmt -recursive

# Validar sintaxe
terraform validate

# Ver state atual
terraform show

# Listar recursos
terraform state list

# Ver outputs
terraform output

# Destruir infraestrutura
terraform destroy

# Aplicar apenas um módulo
terraform apply -target=module.networking
```

## 📝 Variáveis Customizáveis

Edite `terraform.tfvars` para personalizar:

```hcl
project_name       = "cloud4health"
environment        = "dev"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true
```

## 🎓 Disciplinas Aplicadas

- ✅ **Administração de Sistemas Operacionais** - IaC, automação
- ✅ **Arquitetura de Computação em Nuvem** - VPC, Multi-AZ
- ✅ **Arquitetura de Redes** - Subnets, routing, segmentação
- 🔄 **Banco de Dados** - RDS, otimizações (Fase 4)
- 🔄 **Plataformas em Nuvem** - IaaS/PaaS/SaaS (Fase 5)

## 📧 Contato

**Marcos Barbosa Carvalho dos Santos**  
Matrícula: 2025154184  
Instituição: Anhanguera

---

⭐ **Projeto Acadêmico** - Implementação real de infraestrutura AWS seguindo padrões profissionais
