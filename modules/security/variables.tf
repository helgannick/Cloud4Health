# ============================================================================
# Módulo Security - Variáveis
# ============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

# ============================================================================
# Security Groups Configuration
# ============================================================================

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks permitidos para acesso ao ALB (HTTPS)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Internet pública
}

variable "ecs_app_port" {
  description = "Porta da aplicação no ECS"
  type        = number
  default     = 8080
}

variable "rds_port" {
  description = "Porta do PostgreSQL"
  type        = number
  default     = 5432
}

variable "enable_ssh_access" {
  description = "Habilitar acesso SSH (apenas para debugging em dev)"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks permitidos para SSH (se habilitado)"
  type        = list(string)
  default     = []
}

# ============================================================================
# IAM Configuration
# ============================================================================

variable "enable_ecs_exec" {
  description = "Habilitar ECS Exec para debugging"
  type        = bool
  default     = true
}

variable "s3_bucket_arns" {
  description = "ARNs dos buckets S3 que o ECS Task pode acessar"
  type        = list(string)
  default     = []
}

variable "enable_rds_enhanced_monitoring" {
  description = "Habilitar Enhanced Monitoring no RDS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
