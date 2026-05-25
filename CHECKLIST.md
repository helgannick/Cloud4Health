# ✅ Checklist - Cloud4Health Terraform

## 📋 FASE 1: NETWORKING (Concluída)

### Setup Inicial
- [x] Estrutura de diretórios criada
- [x] Módulo de networking desenvolvido
- [x] Variáveis configuradas
- [x] .gitignore criado
- [x] README.md completo
- [x] Documentação de arquitetura

### Recursos de Rede
- [x] VPC (10.0.0.0/16)
- [x] 2x Subnets Públicas (Multi-AZ)
- [x] 2x Subnets Privadas (Multi-AZ)
- [x] 2x Subnets Database (Multi-AZ)
- [x] Internet Gateway
- [x] NAT Gateway
- [x] Route Tables configuradas
- [x] DB Subnet Group
- [x] VPC Flow Logs

### Testes
- [ ] `terraform init` executado com sucesso
- [ ] `terraform validate` sem erros
- [ ] `terraform plan` revisado
- [ ] `terraform apply` executado
- [ ] Outputs verificados
- [ ] VPC visível no console AWS
- [ ] Subnets criadas corretamente
- [ ] NAT Gateway funcionando

### Documentação
- [x] Diagramas de arquitetura
- [x] Tabela de endereçamento IP
- [x] Fluxos de tráfego documentados
- [x] Guia de execução no WSL
- [ ] Screenshots da AWS Console
- [ ] Outputs salvos

---

## 📋 FASE 2: SECURITY (A fazer)

### Security Groups
- [ ] ALB Security Group
  - [ ] Inbound: 443 (HTTPS) from 0.0.0.0/0
  - [ ] Outbound: 8080 to ECS SG

- [ ] ECS Security Group
  - [ ] Inbound: 8080 from ALB SG
  - [ ] Outbound: 5432 to RDS SG
  - [ ] Outbound: 443 to Internet (updates)

- [ ] RDS Security Group
  - [ ] Inbound: 5432 from ECS SG
  - [ ] Outbound: Nenhuma

### IAM Roles
- [ ] ECS Task Execution Role
  - [ ] ECR pull permissions
  - [ ] CloudWatch Logs write
  - [ ] Secrets Manager read

- [ ] ECS Task Role
  - [ ] S3 access (prontuários)
  - [ ] RDS connect
  - [ ] CloudWatch metrics

- [ ] RDS Enhanced Monitoring Role

### Network ACLs (Opcional)
- [ ] Public Subnet NACL
- [ ] Private Subnet NACL
- [ ] Database Subnet NACL

---

## 📋 FASE 3: COMPUTE (A fazer)

### ECS Cluster
- [ ] ECS Cluster criado
- [ ] CloudWatch Container Insights habilitado
- [ ] Capacity Providers configurados

### Application Load Balancer
- [ ] ALB criado em subnets públicas
- [ ] Target Group criado
- [ ] Health Checks configurados
- [ ] HTTPS Listener (porta 443)
- [ ] SSL/TLS Certificate (ACM)

### ECS Service
- [ ] Task Definition criada
- [ ] Service criado
- [ ] Auto Scaling configurado
  - [ ] Min: 2 tasks
  - [ ] Max: 4 tasks
  - [ ] Target CPU: 70%
- [ ] Load Balancer integrado

### Container Registry (ECR)
- [ ] Repositório ECR criado
- [ ] Lifecycle policy configurada
- [ ] Image scanning habilitado

---

## 📋 FASE 4: DATABASE (A fazer)

### RDS PostgreSQL
- [ ] Instance criada (db.t3.micro)
- [ ] Multi-AZ habilitado
- [ ] Automated Backups configurados
  - [ ] Retention: 7 dias
  - [ ] Backup window definido
- [ ] Enhanced Monitoring habilitado
- [ ] Performance Insights habilitado (opcional)

### Database Schema
- [ ] Tabela: Clinicas
- [ ] Tabela: Pacientes
- [ ] Tabela: Profissionais
- [ ] Tabela: Agendamentos
- [ ] Tabela: Prontuarios

### Índices Otimizados
- [ ] idx_paciente_cpf
- [ ] idx_agendamento_data_clinica
- [ ] idx_prontuario_paciente
- [ ] idx_clinica_ativa

### Security
- [ ] Encryption at rest (KMS)
- [ ] Encryption in transit (SSL)
- [ ] Secrets Manager integration
- [ ] IAM Database Authentication

---

## 📋 FASE 5: STORAGE (A fazer)

### S3 Buckets
- [ ] Bucket: Prontuários
  - [ ] Encryption habilitada (SSE-S3)
  - [ ] Versioning habilitado
  - [ ] Lifecycle policy (90d → Glacier)
  - [ ] Block Public Access

- [ ] Bucket: Backups
  - [ ] Replication para outra região
  - [ ] MFA Delete habilitado

- [ ] Bucket: Logs
  - [ ] Lifecycle: 30d → delete
  - [ ] Object Lock (WORM)

### CloudFront (Opcional)
- [ ] Distribution criada
- [ ] Origin: S3 bucket
- [ ] SSL/TLS configurado
- [ ] Cache policies otimizadas

---

## 📋 FASE 6: MONITORING (A fazer)

### CloudWatch
- [ ] Dashboard customizado criado
- [ ] Alarms configurados:
  - [ ] CPU > 80%
  - [ ] Memory > 85%
  - [ ] Disk > 90%
  - [ ] ALB 5xx errors
  - [ ] RDS connections
  - [ ] NAT Gateway errors

### SNS Topics
- [ ] Critical Alerts (email)
- [ ] Warning Alerts (email)
- [ ] Info Notifications (Slack opcional)

### CloudWatch Logs
- [ ] Log Groups criados
  - [ ] /ecs/cloud4health-api
  - [ ] /aws/rds/cloud4health-db
  - [ ] /aws/lambda/cloud4health-*
- [ ] Retention: 7 dias (dev), 30 dias (prod)

### X-Ray (Opcional)
- [ ] X-Ray daemon no ECS
- [ ] Service map configurado
- [ ] Traces habilitados

---

## 📋 FASE 7: APPLICATION (A fazer)

### FastAPI Application
- [ ] Estrutura do projeto criada
- [ ] Endpoints implementados:
  - [ ] GET /health
  - [ ] GET /api/v1/clinicas
  - [ ] GET /api/v1/pacientes
  - [ ] POST /api/v1/agendamentos
  - [ ] GET /api/v1/prontuarios/:id

### Docker
- [ ] Dockerfile criado
- [ ] Multi-stage build otimizado
- [ ] docker-compose.yml para dev
- [ ] Imagem publicada no ECR

### Database Integration
- [ ] SQLAlchemy models
- [ ] Alembic migrations
- [ ] Connection pooling
- [ ] Health checks

### Tests
- [ ] Unit tests
- [ ] Integration tests
- [ ] Load tests (Locust/k6)

---

## 📋 DOCUMENTAÇÃO FINAL (A fazer)

### Diagramas
- [ ] Arquitetura completa (draw.io)
- [ ] Diagrama de rede detalhado
- [ ] Fluxo de dados
- [ ] Diagrama de deployment

### Evidências (Screenshots)
- [ ] VPC Dashboard
- [ ] ECS Cluster
- [ ] RDS Instance
- [ ] S3 Buckets
- [ ] CloudWatch Dashboard
- [ ] Application Load Balancer
- [ ] Security Groups
- [ ] API funcionando (Postman)

### Relatórios
- [ ] Outputs do Terraform
- [ ] Custos mensais (AWS Cost Explorer)
- [ ] Performance metrics
- [ ] Security assessment

### Documento Word (ABNT)
- [ ] Capa
- [ ] Sumário
- [ ] Introdução
- [ ] Passo 1: Administração de SO
- [ ] Passo 2: Arquitetura em Nuvem
- [ ] Passo 3: Arquitetura de Redes
- [ ] Passo 4: Banco de Dados
- [ ] Passo 5: Plataformas e Migração
- [ ] Conclusão
- [ ] Referências (ABNT)
- [ ] Anexos (prints e códigos)

---

## 💰 CONTROLE DE CUSTOS

### Custos Mensais Estimados (por fase)

| Fase | Recursos | Custo/Mês |
|------|----------|-----------|
| 1 - Networking | NAT Gateway, Flow Logs | ~$33 |
| 2 - Security | Grátis | $0 |
| 3 - Compute | ECS Fargate, ALB | ~$21 |
| 4 - Database | RDS t3.micro Multi-AZ | $0 (Free Tier) |
| 5 - Storage | S3 Buckets | ~$2 |
| 6 - Monitoring | CloudWatch, SNS | ~$5 |
| **TOTAL** | | **~$61/mês** |

### Actions para Reduzir Custos
- [ ] Destruir quando não estiver usando
- [ ] Usar VPC Endpoints (S3, ECR)
- [ ] Configurar Auto Scaling adequadamente
- [ ] Revisar logs retention
- [ ] Usar Savings Plans (produção)

---

## 🎯 MILESTONES

- [x] **Milestone 1:** Networking completo (Fase 1) ✅
- [ ] **Milestone 2:** Security + Compute (Fases 2-3)
- [ ] **Milestone 3:** Database + Storage (Fases 4-5)
- [ ] **Milestone 4:** Monitoring + Application (Fases 6-7)
- [ ] **Milestone 5:** Documentação final
- [ ] **Milestone 6:** Entrega do projeto

---

## 📅 Timeline Sugerido

| Período | Tarefas |
|---------|---------|
| **Semana 1** | Fases 1-2 (Network + Security) |
| **Semana 2** | Fase 3 (Compute - ECS + ALB) |
| **Semana 3** | Fases 4-5 (Database + Storage) |
| **Semana 4** | Fase 6-7 (Monitoring + App) |
| **Semana 5** | Testes e otimização |
| **Semana 6** | Documentação final |

---

**🎓 Projeto Acadêmico** - Marcos Barbosa Carvalho dos Santos  
**📧 Matrícula:** 2025154184  
**🏫 Instituição:** Anhanguera
