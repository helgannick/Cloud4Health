# ============================================================================
# Módulo Networking - Outputs
# Exporta IDs e informações para outros módulos
# ============================================================================

# ============================================================================
# VPC Outputs
# ============================================================================
output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN da VPC"
  value       = aws_vpc.main.arn
}

# ============================================================================
# Subnet Outputs
# ============================================================================
output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs das subnets de banco de dados"
  value       = aws_subnet.database[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_cidrs" {
  description = "CIDR blocks das subnets de banco de dados"
  value       = aws_subnet.database[*].cidr_block
}

# ============================================================================
# Gateway Outputs
# ============================================================================
output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_ips" {
  description = "IPs públicos dos NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# ============================================================================
# Route Table Outputs
# ============================================================================
output "public_route_table_id" {
  description = "ID da route table pública"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs das route tables privadas"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "IDs das route tables de banco de dados"
  value       = aws_route_table.database[*].id
}

# ============================================================================
# DB Subnet Group Output
# ============================================================================
output "db_subnet_group_name" {
  description = "Nome do DB subnet group para RDS"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_id" {
  description = "ID do DB subnet group"
  value       = aws_db_subnet_group.main.id
}

# ============================================================================
# Availability Zones Output
# ============================================================================
output "availability_zones" {
  description = "Lista de Availability Zones utilizadas"
  value       = var.availability_zones
}

# ============================================================================
# Flow Logs Output
# ============================================================================
output "flow_logs_log_group_name" {
  description = "Nome do CloudWatch Log Group para VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "flow_logs_role_arn" {
  description = "ARN do IAM Role para VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_iam_role.flow_logs[0].arn : null
}

# ============================================================================
# Network Summary (útil para debugging)
# ============================================================================
output "network_summary" {
  description = "Resumo da configuração de rede"
  value = {
    vpc_id             = aws_vpc.main.id
    vpc_cidr           = aws_vpc.main.cidr_block
    availability_zones = var.availability_zones
    public_subnets     = length(aws_subnet.public)
    private_subnets    = length(aws_subnet.private)
    database_subnets   = length(aws_subnet.database)
    nat_gateways       = length(aws_nat_gateway.main)
    nat_gateway_ips    = aws_eip.nat[*].public_ip
  }
}
