# ============================================================================
# Módulo Security - Outputs
# ============================================================================

# ============================================================================
# Security Groups Outputs
# ============================================================================
output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID do Security Group do ECS"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID do Security Group dos VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "security_group_ids" {
  description = "Map de todos os Security Group IDs"
  value = {
    alb           = aws_security_group.alb.id
    ecs           = aws_security_group.ecs.id
    rds           = aws_security_group.rds.id
    vpc_endpoints = aws_security_group.vpc_endpoints.id
  }
}

# ============================================================================
# IAM Roles Outputs
# ============================================================================
output "ecs_task_execution_role_arn" {
  description = "ARN do ECS Task Execution Role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Nome do ECS Task Execution Role"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ARN do ECS Task Role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Nome do ECS Task Role"
  value       = aws_iam_role.ecs_task.name
}

output "rds_enhanced_monitoring_role_arn" {
  description = "ARN do RDS Enhanced Monitoring Role"
  value       = var.enable_rds_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}

output "lambda_execution_role_arn" {
  description = "ARN do Lambda Execution Role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Nome do Lambda Execution Role"
  value       = aws_iam_role.lambda_execution.name
}

# ============================================================================
# Security Summary
# ============================================================================
output "security_summary" {
  description = "Resumo da configuração de segurança"
  value = {
    security_groups = {
      alb           = aws_security_group.alb.id
      ecs           = aws_security_group.ecs.id
      rds           = aws_security_group.rds.id
      vpc_endpoints = aws_security_group.vpc_endpoints.id
    }
    iam_roles = {
      ecs_task_execution      = aws_iam_role.ecs_task_execution.arn
      ecs_task                = aws_iam_role.ecs_task.arn
      rds_enhanced_monitoring = var.enable_rds_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : "disabled"
      lambda_execution        = aws_iam_role.lambda_execution.arn
    }
    configuration = {
      ecs_exec_enabled                = var.enable_ecs_exec
      rds_enhanced_monitoring_enabled = var.enable_rds_enhanced_monitoring
      ecs_app_port                    = var.ecs_app_port
      rds_port                        = var.rds_port
    }
  }
}

# ============================================================================
# Security Group Rules Summary (para documentação)
# ============================================================================
output "security_rules_summary" {
  description = "Resumo das regras de segurança implementadas"
  value = {
    alb = {
      ingress = "443 (HTTPS), 80 (HTTP) from Internet"
      egress  = "${var.ecs_app_port} to ECS Security Group"
    }
    ecs = {
      ingress = "${var.ecs_app_port} from ALB Security Group"
      egress  = "${var.rds_port} to RDS, 443 (HTTPS) to Internet, 53 (DNS)"
    }
    rds = {
      ingress = "${var.rds_port} from ECS Security Group ONLY"
      egress  = "NONE - Completely isolated"
    }
  }
}
