# ============================================================================
# Módulo Security - Security Groups e IAM Roles
# Well-Architected Framework: Segurança (Defense in Depth)
# ============================================================================

# ============================================================================
# SECURITY GROUPS
# ============================================================================

# ============================================================================
# 1. ALB Security Group
# Permite tráfego HTTPS da Internet → Load Balancer
# ============================================================================
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
      Tier = "Security"
      Type = "ALB"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress: HTTPS da Internet
resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  description       = "Allow HTTPS from Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidr_blocks
  security_group_id = aws_security_group.alb.id
}

# Ingress: HTTP (redirect para HTTPS)
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  description       = "Allow HTTP from Internet (redirect to HTTPS)"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidr_blocks
  security_group_id = aws_security_group.alb.id
}

# Egress: Para ECS Tasks
resource "aws_security_group_rule" "alb_egress_ecs" {
  type                     = "egress"
  description              = "Allow traffic to ECS tasks"
  from_port                = var.ecs_app_port
  to_port                  = var.ecs_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.alb.id
}

# ============================================================================
# 2. ECS Security Group
# Permite tráfego ALB → ECS Tasks → RDS
# ============================================================================
resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-sg-"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
      Tier = "Security"
      Type = "ECS"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress: Do ALB
resource "aws_security_group_rule" "ecs_ingress_alb" {
  type                     = "ingress"
  description              = "Allow traffic from ALB"
  from_port                = var.ecs_app_port
  to_port                  = var.ecs_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
}

# Egress: Para RDS
resource "aws_security_group_rule" "ecs_egress_rds" {
  type                     = "egress"
  description              = "Allow traffic to RDS"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.ecs.id
}

# Egress: Para Internet (updates, API calls, etc.)
resource "aws_security_group_rule" "ecs_egress_https" {
  type              = "egress"
  description       = "Allow HTTPS to Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

# Egress: HTTP (para redirects e chamadas HTTP)
resource "aws_security_group_rule" "ecs_egress_http" {
  type              = "egress"
  description       = "Allow HTTP to Internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

# Egress: DNS
resource "aws_security_group_rule" "ecs_egress_dns_udp" {
  type              = "egress"
  description       = "Allow DNS (UDP)"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_egress_dns_tcp" {
  type              = "egress"
  description       = "Allow DNS (TCP)"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

# ============================================================================
# 3. RDS Security Group
# Permite APENAS tráfego do ECS → RDS (isolamento total)
# ============================================================================
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
      Tier = "Security"
      Type = "RDS"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress: APENAS do ECS
resource "aws_security_group_rule" "rds_ingress_ecs" {
  type                     = "ingress"
  description              = "Allow PostgreSQL from ECS tasks only"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.rds.id
}

# Egress: NENHUMA (RDS não precisa sair para Internet)
# RDS fica completamente isolado

# ============================================================================
# 4. VPC Endpoints Security Group (Opcional - Economia de NAT Gateway)
# Para acessar serviços AWS sem passar pela Internet
# ============================================================================
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-${var.environment}-vpce-sg-"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpce-sg"
      Tier = "Security"
      Type = "VPCEndpoints"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress: Do ECS para endpoints
resource "aws_security_group_rule" "vpce_ingress_ecs" {
  type                     = "ingress"
  description              = "Allow HTTPS from ECS to VPC Endpoints"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.vpc_endpoints.id
}

# Egress: Não necessário (endpoints são apenas destino)

# ============================================================================
# IAM ROLES
# Least Privilege Principle - Cada role tem apenas permissões necessárias
# ============================================================================

# ============================================================================
# 1. ECS Task Execution Role
# Usado pelo ECS Agent para: pull images (ECR), enviar logs (CloudWatch),
# buscar secrets (Secrets Manager)
# ============================================================================
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-exec-"
  description = "ECS Task Execution Role for ${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
      Tier = "Security"
      Type = "IAM"
    }
  )
}

# Policy: Permissões básicas do ECS (managed policy da AWS)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Policy customizada: Secrets Manager (credenciais do RDS)
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-secrets-"
  role        = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.*.amazonaws.com"
          }
        }
      }
    ]
  })
}

# ============================================================================
# 2. ECS Task Role
# Usado pela aplicação em execução para: acessar S3, RDS, CloudWatch, etc.
# ============================================================================
resource "aws_iam_role" "ecs_task" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-task-"
  description = "ECS Task Role for ${var.project_name} application"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-role"
      Tier = "Security"
      Type = "IAM"
    }
  )
}

# Policy: S3 Access (prontuários médicos)
resource "aws_iam_role_policy" "ecs_task_s3" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-s3-"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = concat(
          var.s3_bucket_arns,
          [for arn in var.s3_bucket_arns : "${arn}/*"]
        )
      }
    ]
  })

  # Só criar se houver buckets configurados
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0
}

# Policy: CloudWatch Metrics e Logs (APM da aplicação)
resource "aws_iam_role_policy" "ecs_task_cloudwatch" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-cw-"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy: X-Ray (Distributed Tracing)
resource "aws_iam_role_policy" "ecs_task_xray" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-xray-"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy: ECS Exec (para debugging - opcional)
resource "aws_iam_role_policy" "ecs_task_exec" {
  count       = var.enable_ecs_exec ? 1 : 0
  name_prefix = "${var.project_name}-${var.environment}-ecs-exec-"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================================
# 3. RDS Enhanced Monitoring Role
# Permite que o RDS envie métricas detalhadas para CloudWatch
# ============================================================================
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count       = var.enable_rds_enhanced_monitoring ? 1 : 0
  name_prefix = "${var.project_name}-${var.environment}-rds-monitor-"
  description = "RDS Enhanced Monitoring Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-monitoring-role"
      Tier = "Security"
      Type = "IAM"
    }
  )
}

# Attach managed policy
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.enable_rds_enhanced_monitoring ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================================================
# 4. Lambda Execution Role (se precisar de funções auxiliares)
# Para tarefas como: backup automático, limpeza de logs, etc.
# ============================================================================
resource "aws_iam_role" "lambda_execution" {
  name_prefix = "${var.project_name}-${var.environment}-lambda-"
  description = "Lambda Execution Role for auxiliary functions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-lambda-execution-role"
      Tier = "Security"
      Type = "IAM"
    }
  )
}

# Basic Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access (se Lambda precisar acessar recursos na VPC)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
