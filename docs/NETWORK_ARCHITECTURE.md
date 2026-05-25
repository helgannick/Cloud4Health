# 🌐 Arquitetura de Rede - Cloud4Health

## 📊 Visão Geral

A arquitetura de rede foi projetada seguindo o **AWS Well-Architected Framework** com foco em:
- **Segurança:** Isolamento em camadas
- **Confiabilidade:** Multi-AZ deployment
- **Eficiência:** Roteamento otimizado
- **Escalabilidade:** Preparada para crescimento

## 🏗️ Topologia de Rede

```
                          INTERNET
                             |
                    [Internet Gateway]
                             |
    ┌────────────────────────┴────────────────────────┐
    │                    VPC                           │
    │              10.0.0.0/16                        │
    │                                                  │
    │  ┌──────────────────────────────────────────┐  │
    │  │      PUBLIC SUBNETS (Multi-AZ)           │  │
    │  │                                           │  │
    │  │  AZ-1: 10.0.1.0/24  │ AZ-2: 10.0.2.0/24 │  │
    │  │  ┌───────────────┐  │  ┌───────────────┐│  │
    │  │  │     ALB       │  │  │     ALB       ││  │
    │  │  │ (Load Balancer)│  │  │ (Standby)    ││  │
    │  │  └───────────────┘  │  └───────────────┘│  │
    │  │  ┌───────────────┐  │                    │  │
    │  │  │ NAT Gateway   │  │                    │  │
    │  │  │ (IP Elástico) │  │                    │  │
    │  │  └───────────────┘  │                    │  │
    │  └──────────┬──────────────────────────────┘  │
    │             │                                   │
    │  ┌──────────┴──────────────────────────────┐  │
    │  │    PRIVATE SUBNETS (Multi-AZ)           │  │
    │  │    [ECS Fargate Tasks]                  │  │
    │  │                                          │  │
    │  │  AZ-1: 10.0.11.0/24 │ AZ-2: 10.0.12.0/24│  │
    │  │  ┌───────────────┐  │  ┌───────────────┐│  │
    │  │  │  ECS Task 1   │  │  │  ECS Task 2   ││  │
    │  │  │  (Container)  │  │  │  (Container)  ││  │
    │  │  └───────────────┘  │  └───────────────┘│  │
    │  │  ┌───────────────┐  │  ┌───────────────┐│  │
    │  │  │  ECS Task 3   │  │  │  ECS Task 4   ││  │
    │  │  └───────────────┘  │  └───────────────┘│  │
    │  └──────────────────────────────────────────┘  │
    │                                                  │
    │  ┌──────────────────────────────────────────┐  │
    │  │    DATABASE SUBNETS (Multi-AZ)          │  │
    │  │    [RDS PostgreSQL]                      │  │
    │  │                                          │  │
    │  │  AZ-1: 10.0.21.0/24 │ AZ-2: 10.0.22.0/24│  │
    │  │  ┌───────────────┐  │  ┌───────────────┐│  │
    │  │  │ RDS Primary   │══│══│ RDS Standby   ││  │
    │  │  │ (PostgreSQL)  │  │  │ (Multi-AZ)    ││  │
    │  │  └───────────────┘  │  └───────────────┘│  │
    │  └──────────────────────────────────────────┘  │
    │                                                  │
    └──────────────────────────────────────────────────┘
```

## 📋 Tabela de Endereçamento IP

### VPC Principal
| Recurso | CIDR Block | IPs Disponíveis | Descrição |
|---------|------------|-----------------|-----------|
| VPC | 10.0.0.0/16 | 65,536 | Rede principal |

### Subnets Públicas
| Nome | CIDR | AZ | IPs | Uso |
|------|------|----|----|-----|
| Public Subnet 1 | 10.0.1.0/24 | us-east-1a | 251 | ALB, NAT Gateway |
| Public Subnet 2 | 10.0.2.0/24 | us-east-1b | 251 | ALB (redundância) |

### Subnets Privadas (Aplicação)
| Nome | CIDR | AZ | IPs | Uso |
|------|------|----|----|-----|
| Private Subnet 1 | 10.0.11.0/24 | us-east-1a | 251 | ECS Tasks |
| Private Subnet 2 | 10.0.12.0/24 | us-east-1b | 251 | ECS Tasks |

### Subnets de Banco de Dados
| Nome | CIDR | AZ | IPs | Uso |
|------|------|----|----|-----|
| Database Subnet 1 | 10.0.21.0/24 | us-east-1a | 251 | RDS Primary |
| Database Subnet 2 | 10.0.22.0/24 | us-east-1b | 251 | RDS Standby |

## 🔄 Fluxo de Tráfego

### 1. Tráfego de Entrada (Clientes → Aplicação)
```
Internet
  ↓
Internet Gateway (público)
  ↓
Application Load Balancer (subnet pública)
  ↓
ECS Fargate Tasks (subnet privada)
  ↓
RDS PostgreSQL (subnet database)
```

### 2. Tráfego de Saída (Aplicação → Internet)
```
ECS Fargate Tasks (subnet privada)
  ↓
NAT Gateway (subnet pública)
  ↓
Internet Gateway
  ↓
Internet
```

### 3. Tráfego Interno (Aplicação → Database)
```
ECS Fargate Tasks (10.0.11.0/24)
  ↓ (tráfego interno VPC)
RDS PostgreSQL (10.0.21.0/24)
  ↑ (sem saída para internet)
```

## 🛣️ Tabelas de Roteamento

### Public Route Table
| Destino | Target | Descrição |
|---------|--------|-----------|
| 10.0.0.0/16 | local | Tráfego interno VPC |
| 0.0.0.0/0 | igw-xxx | Internet via IGW |

### Private Route Tables (AZ-1 e AZ-2)
| Destino | Target | Descrição |
|---------|--------|-----------|
| 10.0.0.0/16 | local | Tráfego interno VPC |
| 0.0.0.0/0 | nat-xxx | Internet via NAT Gateway |

### Database Route Tables (AZ-1 e AZ-2)
| Destino | Target | Descrição |
|---------|--------|-----------|
| 10.0.0.0/16 | local | Apenas tráfego interno |
| - | - | **SEM acesso à Internet** |

## 🔒 Camadas de Segurança

### Camada 1: Isolamento de Rede
- ✅ Subnets públicas: Apenas Load Balancer
- ✅ Subnets privadas: ECS Tasks sem IP público
- ✅ Subnets database: Totalmente isoladas

### Camada 2: Security Groups (Fase 2)
```
┌──────────────────────────────────────┐
│ ALB Security Group                    │
│ IN:  443 (HTTPS) from 0.0.0.0/0      │
│ OUT: 8080 to ECS Security Group      │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ ECS Security Group                    │
│ IN:  8080 from ALB Security Group    │
│ OUT: 5432 to RDS Security Group      │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ RDS Security Group                    │
│ IN:  5432 from ECS Security Group    │
│ OUT: Nenhuma saída                    │
└──────────────────────────────────────┘
```

## 🌍 Availability Zones (Alta Disponibilidade)

### Distribuição Multi-AZ
```
┌─────────────────────────────────────────────────┐
│           us-east-1 (Região)                    │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────────────┐    ┌─────────────────┐    │
│  │  us-east-1a     │    │  us-east-1b     │    │
│  ├─────────────────┤    ├─────────────────┤    │
│  │ Public: .1.0/24 │    │ Public: .2.0/24 │    │
│  │ Private: .11/24 │    │ Private: .12/24 │    │
│  │ Database: .21/24│    │ Database: .22/24│    │
│  └─────────────────┘    └─────────────────┘    │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Benefícios Multi-AZ
- ✅ **Tolerância a falhas:** Se uma AZ falhar, outra continua
- ✅ **RDS Multi-AZ:** Replicação síncrona automática
- ✅ **ECS Auto Scaling:** Distribui tasks entre AZs
- ✅ **ALB:** Health checks e failover automático

## 📊 VPC Flow Logs

### Propósito
- Auditoria de tráfego de rede
- Detecção de anomalias
- Troubleshooting de conectividade
- Compliance e segurança

### Formato dos Logs
```
{timestamp} {account-id} {interface-id} {srcaddr} {dstaddr} 
{srcport} {dstport} {protocol} {packets} {bytes} {action}
```

### Retenção
- **7 dias** no CloudWatch Logs
- Logs podem ser exportados para S3 para retenção longa

## 💰 Otimização de Custos

### NAT Gateway - Single vs Multi
| Configuração | Custo/mês | Alta Disponibilidade |
|--------------|-----------|---------------------|
| Single NAT | ~$32 | ❌ (ponto único de falha) |
| Multi NAT (2x) | ~$64 | ✅ (redundância total) |

**Configuração Atual:** Single NAT para economia (dev/testing)  
**Recomendação Produção:** Multi NAT para redundância

### Alternativas para Reduzir Custos
1. **VPC Endpoints** (Gateway)
   - S3 Gateway Endpoint: GRÁTIS
   - DynamoDB Gateway Endpoint: GRÁTIS
   - Reduz tráfego via NAT Gateway

2. **VPC Endpoints** (Interface)
   - ECR, ECS, Secrets Manager, etc.
   - ~$7/mês por endpoint
   - Economiza se tráfego > threshold

## 🎯 Conformidade Well-Architected

### ✅ Pilar Segurança
- Isolamento em camadas (public/private/database)
- VPC Flow Logs habilitados
- Subnets database sem acesso à Internet
- Preparado para Security Groups (Fase 2)

### ✅ Pilar Confiabilidade
- Multi-AZ em todas as camadas
- Redundância de subnets
- DB Subnet Group para RDS Multi-AZ
- NAT Gateway com Elastic IP

### ✅ Pilar Eficiência de Performance
- Subnets otimizadas por função
- Roteamento eficiente
- Preparado para Auto Scaling

### ✅ Pilar Otimização de Custos
- Single NAT Gateway (dev)
- Tags para cost allocation
- VPC Flow Logs com retenção curta

### ✅ Pilar Excelência Operacional
- Infrastructure as Code (Terraform)
- Módulos reutilizáveis
- Documentação completa

## 📝 Próximos Passos (Fase 2)

1. **Security Groups**
   - ALB SG (porta 443)
   - ECS SG (porta 8080)
   - RDS SG (porta 5432)

2. **Network ACLs** (opcional)
   - Camada adicional de segurança
   - Stateless firewall

3. **VPC Endpoints**
   - S3 Gateway Endpoint
   - ECR Interface Endpoint

4. **Route 53** (DNS)
   - Domain registration
   - Health checks

---

📅 **Última atualização:** Fase 1 concluída  
🎓 **Projeto Acadêmico** - Anhanguera - Marcos Barbosa Carvalho dos Santos
