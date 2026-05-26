# ============================================================================
# Cloud4Health - Outputs Principais
# ============================================================================

output "project_info" {
  description = "Informações do projeto"
  value = {
    project_name = var.project_name
    environment  = var.environment
    aws_region   = var.aws_region
    account_id   = data.aws_caller_identity.current.account_id
  }
}

# ============================================================================
# Compute Outputs
# ============================================================================

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "application_url" {
  description = "URL da aplicação"
  value       = module.compute.application_url
}

output "ecs_cluster_name" {
  description = "Nome do ECS Cluster"
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nome do ECS Service"
  value       = module.compute.ecs_service_name
}

output "compute_summary" {
  description = "Resumo da configuração de compute"
  value       = module.compute.compute_summary
}