# ============================================================================
# Cloud4Health - Variáveis Globais do Projeto
# Projeto Integrado - Anhanguera
# Aluno: Marcos Barbosa Carvalho dos Santos
# ============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "cloud4health"
}

variable "environment" {
  description = "Ambiente de deployment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS para deployment"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para subnets privadas"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Habilitar VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default = {
    Project     = "Cloud4Health"
    ManagedBy   = "Terraform"
    Owner       = "Marcos Barbosa"
    Institution = "Anhanguera"
  }
}
