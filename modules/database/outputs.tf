# ============================================================================
# Database Outputs
# ============================================================================

output "db_instance_id" {
  description = "ID da instância RDS"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN da instância RDS"
  value       = aws_db_instance.main.arn
}

output "db_endpoint" {
  description = "Endpoint do RDS"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "Address do RDS"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Nome do database"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Username do database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "secret_arn" {
  description = "ARN do secret com credenciais"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "database_summary" {
  description = "Resumo do database"
  value = {
    endpoint         = aws_db_instance.main.endpoint
    engine          = aws_db_instance.main.engine
    engine_version  = aws_db_instance.main.engine_version
    instance_class  = aws_db_instance.main.instance_class
    multi_az        = aws_db_instance.main.multi_az
    storage_gb      = aws_db_instance.main.allocated_storage
    encrypted       = aws_db_instance.main.storage_encrypted
  }
}