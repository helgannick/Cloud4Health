# 🏥 Cloud4Health - Infraestrutura AWS com Terraform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Status](https://img.shields.io/badge/Status-Concluído-green)

## 📋 Sobre o Projeto

**Projeto Integrado - Anhanguera**  
**Aluno:** Marcos Barbosa Carvalho dos Santos  
**Matrícula:** 2025154184  
**Disciplinas:** Administração de Sistemas Operacionais, Arquitetura de Computação em Nuvem, Arquitetura de Redes, Banco de Dados, Plataformas em Nuvem

Este projeto implementa a modernização completa da infraestrutura da **Cloud4Health**, uma plataforma de tecnologia para clínicas médicas, migrando de uma arquitetura monolítica para uma solução moderna em nuvem AWS utilizando Infrastructure as Code (Terraform).

## 🎯 Objetivos Alcançados

- ✅ Infraestrutura completa em 6 fases (83 recursos AWS)
- ✅ Implementação de containers com ECS Fargate
- ✅ Automação com Terraform (Infrastructure as Code)
- ✅ Arquitetura de rede Multi-AZ moderna e segura
- ✅ Banco de dados PostgreSQL otimizado com RDS
- ✅ Security Groups em camadas (Defense in Depth)
- ✅ Monitoramento com CloudWatch Dashboard
- ✅ Conformidade com AWS Well-Architected Framework
- ✅ Código versionado no GitHub
- ✅ Documentação técnica completa

## 🏗️ Arquitetura Final

``
┌─────────────────────────────────────────────────────────┐
│         Cloud4Health AWS Architecture (Multi-AZ)         │
└─────────────────────────────────────────────────────────┘
Internet
↓
Application Load Balancer (Multi-AZ)
↓
ECS Fargate Service (Auto Scaling 2-4 tasks)
↓
RDS PostgreSQL 15 (Multi-AZ)
↓
S3 Buckets (Prontuários, Backups, Logs)
VPC (10.0.0.0/16) - Multi-AZ (us-east-1a, us-east-1b)
├── Public Subnets (2 AZs) - ALB, NAT Gateway
├── Private Subnets (2 AZs) - ECS Fargate Tasks
└── Database Subnets (2 AZs) - RDS PostgreSQL (isolated)
Monitoring: CloudWatch Dashboard + Alarms
Security: 4 Security Groups + 4 IAM Roles (Least Privilege)
``

## 📁 Estrutura do Projeto

``
cloud4health-terraform/
├── main.tf                  # Configuração principal (6 módulos)
├── variables.tf             # Variáveis globais
├── outputs.tf              # Outputs globais
├── terraform.tfvars        # Valores das variáveis
├── README.md
├── LICENSE (MIT)
├── CHECKLIST.md           # Progresso das fases
├── CONTRIBUTING.md        # Convenções de commit
│
├── modules/
│   ├── networking/         # ✅ FASE 1 - Concluída (18 recursos)
│   ├── security/           # ✅ FASE 2 - Concluída (27 recursos)
│   ├── compute/            # ✅ FASE 3 - Concluída (15 recursos)
│   ├── database/           # ✅ FASE 4 - Concluída (6 recursos)
│   ├── storage/            # ✅ FASE 5 - Concluída (15 recursos)
│   └── monitoring/         # ✅ FASE 6 - Concluída (2 recursos)
│
├── docs/
│   ├── NETWORK_ARCHITECTURE.md    # Arquitetura de rede detalhada
│   ├── SECURITY_ARCHITECTURE.md   # Arquitetura de segurança
│   ├── GIT_GUIDE.md               # Guia de Git
│   └── WSL_GUIDE.md               # Configuração WSL
│
└── scripts/
├── init.sh                     # Inicialização do projeto
├── quick-commit.sh             # Commit automatizado
└── pre-commit-check.sh         # Validação pré-commit
``
## 📊 Recursos AWS Criados

### **TOTAL: 83 recursos**

**Fase 1 - Networking (18 recursos):**
- 1x VPC Multi-AZ (10.0.0.0/16)
- 6x Subnets (2 públicas, 2 privadas, 2 database)
- 1x Internet Gateway
- 1x NAT Gateway
- 5x Route Tables
- 1x DB Subnet Group
- VPC Flow Logs

**Fase 2 - Security (27 recursos):**
- 4x Security Groups (ALB, ECS, RDS, VPC Endpoints)
- 12x Security Group Rules
- 4x IAM Roles (ECS Execution, Task, RDS Monitoring, Lambda)
- 7x IAM Policies

**Fase 3 - Compute (15 recursos):**
- 1x ECS Cluster (Container Insights enabled)
- 1x ECS Service (2 tasks)
- 1x Task Definition (nginx:alpine)
- 1x Application Load Balancer
- 1x Target Group
- 2x Listeners (HTTP 80, HTTPS 443)
- 1x CloudWatch Log Group
- 4x Auto Scaling Policies (CPU, Memory, Requests)
- 3x CloudWatch Alarms

**Fase 4 - Database (6 recursos):**
- 1x RDS PostgreSQL 15 (Multi-AZ, db.t3.micro)
- 1x DB Parameter Group
- 1x Secrets Manager Secret
- Encryption at rest enabled
- Enhanced Monitoring enabled
- Performance Insights enabled

**Fase 5 - Storage (15 recursos):**
- 3x S3 Buckets (prontuários, backups, logs)
- Versioning enabled (prontuários, backups)
- Encryption (AES256) em todos
- Lifecycle: 90d → Glacier (prontuários)
- Lifecycle: 30d → Delete (logs)
- Block Public Access em todos

**Fase 6 - Monitoring (2 recursos):**
- 1x CloudWatch Dashboard (7 widgets)
- 1x SNS Topic (alerts)

## 💰 Estimativa de Custos

| Fase | Recursos | Custo/Mês |
|------|----------|-----------|
| Networking | 18 | ~$33 (NAT Gateway) |
| Security | 27 | $0 (grátis) |
| Compute | 15 | ~$35 (ECS + ALB) |
| Database | 6 | ~$15 (db.t3.micro) |
| Storage | 15 | ~$2 (S3 usage) |
| Monitoring | 2 | ~$3 (dashboard) |
| **TOTAL** | **83** | **~$88/mês** |

**Custo 1 dia completo:** ~$2-3  
**Estratégia aplicada:** ✅ Infraestrutura destruída após captura de evidências = **$0**

## 🔒 AWS Well-Architected Framework

### ✅ **Excelência Operacional**
- Infrastructure as Code (Terraform)
- Módulos reutilizáveis
- Versionamento Git
- Scripts de automação
- Documentação completa

### ✅ **Segurança**
- Defense in Depth (4 camadas de Security Groups)
- Least Privilege (IAM Roles específicos)
- Encryption at rest (RDS, S3)
- Encryption in transit (TLS)
- Secrets Manager para credenciais
- Database em subnet isolada (zero egress)
- VPC Flow Logs

### ✅ **Confiabilidade**
- Multi-AZ deployment (RDS, ECS, ALB)
- Auto Scaling (CPU, Memory, Requests)
- Health checks automáticos
- Automated backups (RDS 7 dias, S3 versioning)
- CloudWatch Alarms

### ✅ **Eficiência de Performance**
- ECS Fargate serverless
- Auto Scaling baseado em métricas
- Performance Insights (RDS)
- Container Insights (ECS)
- CloudWatch Dashboard

### ✅ **Otimização de Custos**
- Free Tier maximizado
- Single NAT Gateway
- S3 Lifecycle policies
- Right-sized instances
- Auto Scaling (paga só o necessário)
- Tags para cost allocation
- **Destruição pós-documentação (custo zero)**

### ✅ **Sustentabilidade**
- Serverless onde possível
- Auto-shutdown capability
- Recursos sob demanda

## 🚀 Como Usar Este Projeto

### **Pré-requisitos:**
- AWS CLI configurado
- Terraform >= 1.0
- Git
- Conta AWS (Free Tier recomendado)

### **Deploy Completo:**

```bash
# 1. Clonar repositório
git clone https://github.com/helgannick/Cloud4Health.git
cd Cloud4Health

# 2. Configurar credenciais AWS
aws configure

# 3. Inicializar Terraform
terraform init

# 4. Validar
terraform validate

# 5. Planejar (deve mostrar 83 recursos)
terraform plan

# 6. Aplicar
terraform apply

# 7. Ver outputs
terraform output

# 8. DESTRUIR quando terminar (IMPORTANTE!)
terraform destroy
```

### **Deploy por Fases:**

```bash
# Aplicar apenas Networking
terraform apply -target=module.networking

# Aplicar apenas Security
terraform apply -target=module.security

# E assim por diante...
```

## 📸 Evidências do Projeto

✅ **83 recursos criados na AWS**  
✅ **Aplicação funcionando:** nginx respondendo via ALB  
✅ **Prints coletados de todas as fases**  
✅ **Infraestrutura destruída após testes**  
✅ **Código preservado no GitHub**

## 🎓 Disciplinas do Projeto Integrado

### **Passo 1 - Administração de Sistemas Operacionais**
- ✅ IaC com Terraform (automação)
- ✅ ECS Task Management
- ✅ CloudWatch Logs
- ✅ Scripts de automação
- ✅ VPC Flow Logs

### **Passo 2 - Arquitetura de Computação em Nuvem**
- ✅ VPC Multi-AZ completa
- ✅ Security Groups (Defense in Depth)
- ✅ IAM Roles (Least Privilege)
- ✅ Conformidade LGPD
- ✅ Well-Architected Framework

### **Passo 3 - Arquitetura de Redes**
- ✅ Modernização LAN (subnets segmentadas)
- ✅ Integração nuvem híbrida
- ✅ Route Tables configuradas
- ✅ Protocolos TCP/IP, DNS

### **Passo 4 - Programação e Banco de Dados**
- ✅ RDS PostgreSQL otimizado
- ✅ Multi-AZ alta disponibilidade
- ✅ Performance Insights
- ✅ Índices planejados

### **Passo 5 - Plataformas e Migração em Nuvem**
- ✅ IaaS: VPC, ECS, RDS
- ✅ PaaS: ECS Fargate, RDS Managed
- ✅ Responsabilidade compartilhada
- ✅ Migração monolítico → containers

## 🔧 Comandos Úteis

```bash
# Ver todos os recursos
terraform state list

# Ver outputs
terraform output

# Formatar código
terraform fmt -recursive

# Validar sintaxe
terraform validate

# Ver plano
terraform plan

# Aplicar
terraform apply

# Destruir TUDO
terraform destroy
```

## 📝 Commits Organizados

Projeto segue **Conventional Commits**:
- `feat(módulo):` Nova funcionalidade
- `fix(módulo):` Correção de bug
- `docs:` Documentação
- `chore:` Tarefas auxiliares

Histórico completo: `git log --oneline --graph`

## ⚠️ Importante

- ✅ **Infraestrutura foi DESTRUÍDA** após captura de evidências
- ✅ **Código preservado** no GitHub para avaliação
- ✅ **Prints coletados** para documentação acadêmica
- ✅ **Custo ZERO** mantendo apenas o repositório

## 📧 Contato

**Marcos Barbosa Carvalho dos Santos**  
Matrícula: 2025154184  
Instituição: Anhanguera  
Repositório: https://github.com/helgannick/Cloud4Health

---

⭐ **Projeto Acadêmico Concluído** - Implementação completa de infraestrutura AWS seguindo padrões profissionais do Well-Architected Framework

**Status:** ✅ 6 Fases Completas | 83 Recursos | Infraestrutura Destruída | Evidências Preservadas