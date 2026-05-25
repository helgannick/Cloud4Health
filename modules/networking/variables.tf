# ============================================================================
# Módulo Networking - Variáveis
# ============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas (aplicação)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks para subnets de banco de dados"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar apenas um NAT Gateway (economia de custos)"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Habilitar VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Habilitar VPC Flow Logs para auditoria"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
