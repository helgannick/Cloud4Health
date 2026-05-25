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
