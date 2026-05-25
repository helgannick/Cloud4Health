# 🔒 Arquitetura de Segurança - Cloud4Health

## 📊 Visão Geral

A arquitetura de segurança implementa **Defense in Depth** (defesa em camadas) seguindo o AWS Well-Architected Framework, com foco no princípio de **Least Privilege** (mínimo privilégio).

---

## 🛡️ Security Groups (Firewall de Rede)

### Arquitetura de Camadas

```
┌────────────────────────────────────────────────────┐
│               INTERNET                              │
└────────────────┬───────────────────────────────────┘
                 │
          ┌──────▼──────┐
          │   ALB SG    │ HTTPS (443), HTTP (80)
          │  Public     │ FROM: 0.0.0.0/0
          └──────┬──────┘ TO: ECS SG:8080
                 │
          ┌──────▼──────┐
          │   ECS SG    │ Port 8080
          │  Private    │ FROM: ALB SG
          └──────┬──────┘ TO: RDS SG:5432, Internet:443
                 │
          ┌──────▼──────┐
          │   RDS SG    │ Port 5432
          │  Database   │ FROM: ECS SG ONLY
          └─────────────┘ TO: NONE (isolated)
```

---

## 📋 Tabela de Security Groups

### 1. ALB Security Group
**Propósito:** Load Balancer público (ponto de entrada)

| Direção | Protocolo | Porta | Origem/Destino | Descrição |
|---------|-----------|-------|----------------|-----------|
| Ingress | TCP | 443 | 0.0.0.0/0 | HTTPS da Internet |
| Ingress | TCP | 80 | 0.0.0.0/0 | HTTP (redirect p/ HTTPS) |
| Egress | TCP | 8080 | ECS SG | Tráfego para aplicação |

**Justificativa:**
- Porta 443: Padrão HTTPS para comunicação segura
- Porta 80: Permite redirects automáticos para HTTPS
- Egress restrito: Apenas para ECS, não acessa Internet

---

### 2. ECS Security Group
**Propósito:** Containers da aplicação (camada privada)

| Direção | Protocolo | Porta | Origem/Destino | Descrição |
|---------|-----------|-------|----------------|-----------|
| Ingress | TCP | 8080 | ALB SG | Tráfego do Load Balancer |
| Egress | TCP | 5432 | RDS SG | Conexão com banco de dados |
| Egress | TCP | 443 | 0.0.0.0/0 | HTTPS (updates, APIs) |
| Egress | TCP | 80 | 0.0.0.0/0 | HTTP (redirects) |
| Egress | UDP | 53 | 0.0.0.0/0 | DNS resolution |
| Egress | TCP | 53 | 0.0.0.0/0 | DNS resolution (TCP) |

**Justificativa:**
- Porta 8080: Non-privileged port para aplicação
- Ingress do ALB: Único ponto de entrada autorizado
- HTTPS/HTTP saída: Para chamadas a APIs externas, downloads
- DNS: Essencial para resolução de nomes

---

### 3. RDS Security Group
**Propósito:** Banco de dados PostgreSQL (máxima isolação)

| Direção | Protocolo | Porta | Origem/Destino | Descrição |
|---------|-----------|-------|----------------|-----------|
| Ingress | TCP | 5432 | ECS SG | PostgreSQL do ECS APENAS |
| Egress | - | - | NONE | **SEM acesso externo** |

**Justificativa:**
- **Isolamento total:** Banco só aceita conexões do ECS
- **Zero egress:** RDS não precisa sair para Internet
- **Defense in Depth:** Mesmo se ECS comprometido, RDS protegido

---

### 4. VPC Endpoints Security Group
**Propósito:** Acesso privado a serviços AWS (economia de NAT)

| Direção | Protocolo | Porta | Origem/Destino | Descrição |
|---------|-----------|-------|----------------|-----------|
| Ingress | TCP | 443 | ECS SG | HTTPS do ECS para endpoints |

**Uso futuro:** S3 Gateway, ECR Interface, Secrets Manager

---

## 🔑 IAM Roles (Controle de Acesso)

### Arquitetura de Permissões

```
┌─────────────────────────────────────────────────────┐
│  ECS Task Definition                                 │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │ Task Execution Role                        │    │
│  │ (usado pelo ECS Agent)                     │    │
│  │                                             │    │
│  │ Permissions:                                │    │
│  │ • Pull images from ECR                     │    │
│  │ • Write logs to CloudWatch                 │    │
│  │ • Read secrets from Secrets Manager        │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │ Task Role                                   │    │
│  │ (usado pela aplicação em execução)         │    │
│  │                                             │    │
│  │ Permissions:                                │    │
│  │ • Read/Write S3 buckets                    │    │
│  │ • Connect to RDS                            │    │
│  │ • Send metrics to CloudWatch               │    │
│  │ • X-Ray tracing                             │    │
│  │ • (Optional) ECS Exec for debugging        │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

## 📝 IAM Roles Detalhados

### 1. ECS Task Execution Role

**Quem usa:** ECS Agent (infraestrutura)  
**Quando:** Durante startup do container

**Permissões:**

```json
{
  "Effect": "Allow",
  "Action": [
    // ECR - Pull de imagens Docker
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    
    // CloudWatch Logs - Enviar logs
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    
    // Secrets Manager - Credenciais do RDS
    "secretsmanager:GetSecretValue",
    
    // KMS - Decrypt secrets
    "kms:Decrypt"
  ]
}
```

**Por quê Least Privilege:**
- ✅ Acesso SOMENTE a secrets com prefixo `cloud4health/dev/*`
- ✅ KMS decrypt SOMENTE via Secrets Manager
- ✅ Sem permissões de escrita desnecessárias

---

### 2. ECS Task Role

**Quem usa:** Aplicação (código da FastAPI/Python)  
**Quando:** Durante execução do container

**Permissões:**

**S3 Access:**
```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",      // Ler prontuários
    "s3:PutObject",      // Salvar prontuários
    "s3:DeleteObject",   // Remover arquivos
    "s3:ListBucket"      // Listar arquivos
  ],
  "Resource": [
    "arn:aws:s3:::cloud4health-prontuarios/*",
    "arn:aws:s3:::cloud4health-prontuarios"
  ]
}
```

**CloudWatch Metrics:**
```json
{
  "Effect": "Allow",
  "Action": [
    "cloudwatch:PutMetricData",  // Custom metrics
    "logs:PutLogEvents"          // Application logs
  ]
}
```

**X-Ray Tracing:**
```json
{
  "Effect": "Allow",
  "Action": [
    "xray:PutTraceSegments",
    "xray:PutTelemetryRecords"
  ]
}
```

**ECS Exec (Debugging - Opcional):**
```json
{
  "Effect": "Allow",
  "Action": [
    "ssmmessages:CreateControlChannel",
    "ssmmessages:OpenDataChannel"
  ]
}
```

**Por quê Least Privilege:**
- ✅ S3 acesso SOMENTE aos buckets específicos
- ✅ RDS connection via Security Groups (não IAM)
- ✅ Sem permissões administrativas
- ✅ ECS Exec opcional (pode desabilitar em prod)

---

### 3. RDS Enhanced Monitoring Role

**Quem usa:** RDS Service  
**Quando:** Enviar métricas detalhadas para CloudWatch

**Permissões:**
- AWS Managed Policy: `AmazonRDSEnhancedMonitoringRole`

**Métricas coletadas:**
- CPU, memória, disco, rede
- Processos do PostgreSQL
- Estado das conexões

---

### 4. Lambda Execution Role

**Quem usa:** Funções Lambda (tarefas auxiliares)  
**Quando:** Backups, limpeza, automações

**Permissões:**
- AWS Managed Policy: `AWSLambdaBasicExecutionRole`
- AWS Managed Policy: `AWSLambdaVPCAccessExecutionRole`

**Uso futuro:**
- Backup automático de dados
- Limpeza de logs antigos
- Notificações customizadas

---

## 🔐 Princípios de Segurança Implementados

### 1. Least Privilege (Mínimo Privilégio)
- ✅ Cada role tem APENAS permissões necessárias
- ✅ Sem permissões `*` (wildcards excessivos)
- ✅ Resource ARNs específicos quando possível

### 2. Defense in Depth (Defesa em Camadas)
```
Layer 1: Network (Security Groups)
Layer 2: IAM (Roles e Policies)
Layer 3: Encryption (em trânsito e repouso)
Layer 4: Monitoring (CloudWatch, VPC Flow Logs)
```

### 3. Separation of Duties
- ✅ Task Execution Role ≠ Task Role
- ✅ Infraestrutura vs Aplicação separadas

### 4. Zero Trust
- ✅ RDS sem acesso à Internet
- ✅ Containers em subnets privadas
- ✅ Apenas ALB público

---

## 📊 Matriz de Responsabilidades

| Recurso | Pode Acessar | NÃO Pode Acessar |
|---------|--------------|------------------|
| **Internet** | → ALB (443, 80) | → ECS, RDS |
| **ALB** | → ECS (8080) | → RDS, Internet |
| **ECS** | → RDS (5432)<br>→ Internet (443, 80)<br>→ S3 buckets<br>→ CloudWatch | → Outros ECS tasks |
| **RDS** | Nada | → Internet<br>→ Qualquer saída |

---

## 🎯 Conformidade Well-Architected

### ✅ Pilar Segurança

**Identidade e Controle de Acesso:**
- IAM Roles com least privilege
- Sem credenciais hardcoded
- Secrets no Secrets Manager

**Detecção:**
- VPC Flow Logs habilitados
- CloudWatch Logs de aplicação
- X-Ray para tracing

**Proteção de Infraestrutura:**
- Security Groups em camadas
- Subnets privadas para ECS e RDS
- Network ACLs (futuro)

**Proteção de Dados:**
- Encryption at rest (RDS KMS)
- Encryption in transit (TLS)
- S3 bucket encryption

---

## 🔄 Fluxo de Tráfego Seguro

### Request Flow (Cliente → Database)
```
1. Cliente (Internet)
   ↓ HTTPS (443)
2. ALB (Public Subnet)
   ↓ HTTP (8080) - Security Group permite ALB → ECS
3. ECS Task (Private Subnet)
   ↓ PostgreSQL (5432) - Security Group permite ECS → RDS
4. RDS (Database Subnet - ISOLADO)
```

### Response Flow (Database → Cliente)
```
1. RDS → ECS (mesma conexão)
2. ECS → ALB (mesma conexão)
3. ALB → Internet (HTTPS)
```

---

## 🆘 Troubleshooting

### ECS não consegue acessar RDS
**Verificar:**
```bash
# Security Group correto?
aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

# RDS aceita conexões do ECS SG?
# Verificar ingress rules do RDS SG
```

### ECS não consegue pull de imagem ECR
**Verificar:**
```bash
# Task Execution Role tem permissões ECR?
aws iam get-role-policy --role-name cloud4health-dev-ecs-exec-xxxxx

# Subnet privada tem rota para NAT Gateway?
aws ec2 describe-route-tables --route-table-id rtb-xxxxxxxx
```

---

## 📚 Próximos Passos (Fase 3)

Na Fase 3, vamos usar estes Security Groups e IAM Roles para:
- ✅ Criar Application Load Balancer (usa ALB SG)
- ✅ Criar ECS Fargate Service (usa ECS SG + Task Roles)
- ✅ Criar RDS PostgreSQL (usa RDS SG + Monitoring Role)

---

**🎓 Projeto Acadêmico** - Cloud4Health  
**📅 Fase 2:** Security Completa  
**👤 Autor:** Marcos Barbosa Carvalho dos Santos
