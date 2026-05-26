# ============================================================================
# Cloud4Health - Infraestrutura Principal
# Projeto Integrado - Anhanguera
# Aluno: Marcos Barbosa Carvalho dos Santos
# Matrícula: 2025154184
# ============================================================================
# 
# Arquitetura baseada no AWS Well-Architected Framework:
# - Excelência Operacional: IaC com Terraform, GitOps
# - Segurança: Isolamento de rede, VPC Flow Logs
# - Confiabilidade: Multi-AZ, redundância
# - Eficiência de Performance: Containers, serverless
# - Otimização de Custos: Free Tier, Auto Scaling
# - Sustentabilidade: Recursos sob demanda
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 para state remoto (descomente após criar bucket)
  # backend "s3" {
  #   bucket         = "cloud4health-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "cloud4health-terraform-locks"
  # }
}

# ============================================================================
# Provider AWS
# ============================================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# ============================================================================
# Data Sources - Obter informações da AWS
# ============================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ============================================================================
# MÓDULO 1: NETWORKING
# Infraestrutura de rede completa com VPC, Subnets, Gateways
# ============================================================================
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  # NAT Gateway Configuration
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true # Economia de custos (use false para prod)

  # VPN Gateway (opcional)
  enable_vpn_gateway = var.enable_vpn_gateway

  # DNS
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Security
  enable_flow_logs = true

  tags = var.tags
}

# ============================================================================
# MÓDULO 2: SECURITY
# Security Groups e IAM Roles
# ============================================================================
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment

  # VPC Info (do módulo networking)
  vpc_id   = module.networking.vpc_id
  vpc_cidr = module.networking.vpc_cidr

  # Security Groups Configuration
  alb_ingress_cidr_blocks = ["0.0.0.0/0"] # Internet pública
  ecs_app_port            = 80          # Porta da aplicação
  rds_port                = 5432          # PostgreSQL

  # IAM Configuration
  enable_ecs_exec                = true # Habilitar ECS Exec para debugging
  enable_rds_enhanced_monitoring = true # Métricas detalhadas do RDS
  s3_bucket_arns                 = []   # Será preenchido na Fase 5

  # SSH (apenas para dev/debugging - desabilitado por padrão)
  enable_ssh_access = false

  tags = var.tags
}

# ============================================================================
# MÓDULO 3: COMPUTE
# ECS Fargate, Application Load Balancer, Auto Scaling
# ============================================================================
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment

  # Networking (do módulo networking)
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  # Security (do módulo security)
  alb_security_group_id       = module.security.alb_security_group_id
  ecs_security_group_id       = module.security.ecs_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn

  # ECS Configuration
  container_name   = "cloud4health-api"
  container_port   = 80
  container_cpu    = 256            # 0.25 vCPU
  container_memory = 512            # 512 MB
  container_image  = "nginx:alpine" # Placeholder até criar aplicação

  # Service Configuration
  desired_count = 2 # Alta disponibilidade

  # Auto Scaling
  min_capacity        = 2
  max_capacity        = 4
  cpu_target_value    = 70
  memory_target_value = 80

  # Health Check
  health_check_path     = "/"
  health_check_interval = 30
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 3

  # ECS Exec (debugging)
  enable_execute_command = true

  tags = var.tags
}

# ============================================================================
# Outputs Globais
# ============================================================================

# Account Info
output "aws_account_id" {
  description = "ID da conta AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Região AWS sendo utilizada"
  value       = data.aws_region.current.name
}

# Networking Outputs
output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs das subnets de banco de dados"
  value       = module.networking.database_subnet_ids
}

output "nat_gateway_ips" {
  description = "IPs públicos dos NAT Gateways"
  value       = module.networking.nat_gateway_ips
}

output "network_summary" {
  description = "Resumo da configuração de rede"
  value       = module.networking.network_summary
}

# Security Outputs
output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = module.security.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ID do Security Group do ECS"
  value       = module.security.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = module.security.rds_security_group_id
}

output "ecs_task_execution_role_arn" {
  description = "ARN do ECS Task Execution Role"
  value       = module.security.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN do ECS Task Role"
  value       = module.security.ecs_task_role_arn
}

output "security_summary" {
  description = "Resumo da configuração de segurança"
  value       = module.security.security_summary
}
