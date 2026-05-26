# ============================================================================
# RDS PostgreSQL - Multi-AZ
# ============================================================================

# Gerar senha aleatória
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Armazenar senha no Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "${var.project_name}/${var.environment}/rds-"
  description = "RDS PostgreSQL password"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.endpoint
    port     = var.db_port
    dbname   = var.db_name
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = var.db_port

  # Network
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  # High Availability
  multi_az = var.multi_az

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn            = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Protection
  deletion_protection = false # Para facilitar destroy
  skip_final_snapshot = true  # Para facilitar destroy

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rds"
    }
  )
}

# Parameter Group customizado
resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-"
  family      = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = var.tags
}