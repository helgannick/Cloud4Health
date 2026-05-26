# ============================================================================
# Módulo Compute - ECS Fargate Cluster e Service
# Well-Architected Framework: Eficiência de Performance + Confiabilidade
# ============================================================================

# ============================================================================
# ECS Cluster
# ============================================================================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-cluster"
      Tier = "Compute"
    }
  )
}

# ============================================================================
# CloudWatch Log Group para ECS Tasks
# ============================================================================
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-logs"
      Tier = "Monitoring"
    }
  )
}

# ============================================================================
# ECS Task Definition
# Define: CPU, Memory, Container, Networking
# ============================================================================
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "PROJECT_NAME"
          value = var.project_name
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-task-definition"
      Tier = "Compute"
    }
  )
}

# ============================================================================
# ECS Service
# Gerencia tasks, integração com ALB, health checks
# ============================================================================
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Estratégia de deployment
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  # Configuração de rede
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  # Integração com Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # ECS Exec para debugging
  enable_execute_command = var.enable_execute_command

  # Dependências
  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-service"
      Tier = "Compute"
    }
  )

  lifecycle {
    ignore_changes = [desired_count] # Auto Scaling vai gerenciar
  }
}

# ============================================================================
# Data Sources
# ============================================================================
data "aws_region" "current" {}