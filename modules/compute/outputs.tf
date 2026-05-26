# ============================================================================
# Módulo Compute - Outputs
# ============================================================================

# ============================================================================
# ECS Cluster Outputs
# ============================================================================
output "ecs_cluster_id" {
  description = "ID do ECS Cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "Nome do ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN do ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

# ============================================================================
# ECS Service Outputs
# ============================================================================
output "ecs_service_id" {
  description = "ID do ECS Service"
  value       = aws_ecs_service.app.id
}

output "ecs_service_name" {
  description = "Nome do ECS Service"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN da Task Definition"
  value       = aws_ecs_task_definition.app.arn
}

# ============================================================================
# ALB Outputs
# ============================================================================
output "alb_id" {
  description = "ID do Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name do ALB (use este para acessar a aplicação)"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID do ALB (para Route53)"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "Nome do Target Group"
  value       = aws_lb_target_group.app.name
}

# ============================================================================
# CloudWatch Outputs
# ============================================================================
output "cloudwatch_log_group_name" {
  description = "Nome do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.ecs.arn
}

# ============================================================================
# Auto Scaling Outputs
# ============================================================================
output "autoscaling_target_id" {
  description = "ID do Auto Scaling Target"
  value       = aws_appautoscaling_target.ecs.id
}

output "autoscaling_min_capacity" {
  description = "Capacidade mínima de tasks"
  value       = var.min_capacity
}

output "autoscaling_max_capacity" {
  description = "Capacidade máxima de tasks"
  value       = var.max_capacity
}

# ============================================================================
# Application URL
# ============================================================================
output "application_url" {
  description = "URL para acessar a aplicação"
  value       = "http://${aws_lb.main.dns_name}"
}

output "application_https_url" {
  description = "URL HTTPS (quando certificado configurado)"
  value       = "https://${aws_lb.main.dns_name}"
}

# ============================================================================
# Compute Summary
# ============================================================================
output "compute_summary" {
  description = "Resumo da configuração de compute"
  value = {
    ecs = {
      cluster_name     = aws_ecs_cluster.main.name
      service_name     = aws_ecs_service.app.name
      desired_count    = var.desired_count
      container_cpu    = var.container_cpu
      container_memory = var.container_memory
    }
    alb = {
      dns_name     = aws_lb.main.dns_name
      url          = "http://${aws_lb.main.dns_name}"
      target_group = aws_lb_target_group.app.name
    }
    autoscaling = {
      min_capacity  = var.min_capacity
      max_capacity  = var.max_capacity
      cpu_target    = var.cpu_target_value
      memory_target = var.memory_target_value
    }
    monitoring = {
      log_group          = aws_cloudwatch_log_group.ecs.name
      container_insights = "enabled"
    }
  }
}