# ============================================================================
# Cloud4Health - Valores de Variáveis para Ambiente de Desenvolvimento
# ============================================================================

project_name       = "cloud4health"
environment        = "dev"
aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true
enable_vpn_gateway = false

# DNS Configuration
enable_dns_hostnames = true
enable_dns_support   = true

# Tags
tags = {
  Project     = "Cloud4Health"
  Environment = "Development"
  ManagedBy   = "Terraform"
  Owner       = "Marcos Barbosa Carvalho dos Santos"
  Institution = "Anhanguera"
  Course      = "Administração de Sistemas"
  Discipline  = "Projeto Integrado"
}
