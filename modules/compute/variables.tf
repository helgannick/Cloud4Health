# ============================================================================
# Módulo Compute - Variáveis
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

variable "public_subnet_ids" {
  description = "IDs das subnets públicas para ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID do Security Group do ECS"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN do ECS Task Execution Role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN do ECS Task Role"
  type        = string
}

# ============================================================================
# ECS Configuration
# ============================================================================

variable "container_name" {
  description = "Nome do container"
  type        = string
  default     = "cloud4health-api"
}

variable "container_port" {
  description = "Porta do container"
  type        = number
  default     = 8080
}

variable "container_cpu" {
  description = "CPU units para o container (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memória em MB para o container (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Número desejado de tasks"
  type        = number
  default     = 2
}

# ============================================================================
# Auto Scaling Configuration
# ============================================================================

variable "min_capacity" {
  description = "Mínimo de tasks (alta disponibilidade)"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Máximo de tasks"
  type        = number
  default     = 4
}

variable "cpu_target_value" {
  description = "Target CPU utilization para auto scaling (%)"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization para auto scaling (%)"
  type        = number
  default     = 80
}

# ============================================================================
# ALB Configuration
# ============================================================================

variable "health_check_path" {
  description = "Path para health check"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Intervalo entre health checks (segundos)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout do health check (segundos)"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Número de health checks bem sucedidos para considerar healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Número de health checks falhados para considerar unhealthy"
  type        = number
  default     = 3
}

variable "deregistration_delay" {
  description = "Tempo de espera antes de remover target (segundos)"
  type        = number
  default     = 30
}

# ============================================================================
# Container Image
# ============================================================================

variable "container_image" {
  description = "Imagem Docker (será ECR depois)"
  type        = string
  default     = "nginx:alpine" # Placeholder até termos a aplicação
}

variable "enable_execute_command" {
  description = "Habilitar ECS Exec para debugging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}