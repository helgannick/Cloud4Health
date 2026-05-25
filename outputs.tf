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
