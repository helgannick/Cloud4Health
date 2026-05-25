# ============================================================================
# Módulo Networking - Infraestrutura de Rede
# Well-Architected Framework: Confiabilidade (Multi-AZ) + Segurança (Isolamento)
# ============================================================================

# ============================================================================
# VPC - Virtual Private Cloud
# ============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
      Tier = "Network"
    }
  )
}

# ============================================================================
# Internet Gateway - Acesso à Internet para recursos públicos
# ============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
      Tier = "Network"
    }
  )
}

# ============================================================================
# Subnets Públicas - Para Load Balancer e NAT Gateway
# Multi-AZ para alta disponibilidade (Well-Architected: Confiabilidade)
# ============================================================================
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Tier = "Public"
      AZ   = var.availability_zones[count.index]
      Type = "public"
    }
  )
}

# ============================================================================
# Subnets Privadas - Para ECS Tasks (Aplicação)
# Isolamento de rede (Well-Architected: Segurança)
# ============================================================================
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Tier = "Private"
      AZ   = var.availability_zones[count.index]
      Type = "private"
    }
  )
}

# ============================================================================
# Subnets de Banco de Dados - Camada isolada para RDS
# Segmentação adicional (Well-Architected: Segurança)
# ============================================================================
resource "aws_subnet" "database" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-database-subnet-${count.index + 1}"
      Tier = "Database"
      AZ   = var.availability_zones[count.index]
      Type = "database"
    }
  )
}

# ============================================================================
# Elastic IP para NAT Gateway
# ============================================================================
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
      Tier = "Network"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# NAT Gateway - Permite que recursos privados acessem a Internet
# Well-Architected: Confiabilidade (saída controlada)
# NOTA: single_nat_gateway=true reduz custos (~$32/mês), mas remove redundância
# ============================================================================
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
      Tier = "Network"
      AZ   = var.availability_zones[count.index]
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# Route Table - Subnet Pública
# Roteia tráfego para Internet via Internet Gateway
# ============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
      Tier = "Network"
      Type = "public"
    }
  )
}

# Rota para Internet
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associar Route Table com Subnets Públicas
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# Route Tables - Subnets Privadas
# Roteia tráfego para Internet via NAT Gateway
# ============================================================================
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
      Tier = "Network"
      Type = "private"
      AZ   = var.availability_zones[count.index]
    }
  )
}

# Rota para Internet via NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Associar Route Tables com Subnets Privadas
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================================
# Route Tables - Subnets de Banco de Dados
# Sem rota para Internet (máxima segurança)
# ============================================================================
resource "aws_route_table" "database" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-database-rt-${count.index + 1}"
      Tier = "Database"
      Type = "database"
      AZ   = var.availability_zones[count.index]
    }
  )
}

# Associar Route Tables com Subnets de Database
resource "aws_route_table_association" "database" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# ============================================================================
# VPC Flow Logs - Auditoria de tráfego de rede
# Well-Architected: Excelência Operacional + Segurança
# ============================================================================
resource "aws_flow_log" "main" {
  count                    = var.enable_flow_logs ? 1 : 0
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.main.id
  max_aggregation_interval = 60

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
      Tier = "Security"
    }
  )
}

# CloudWatch Log Group para Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.project_name}-${var.environment}-flow-logs"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-flow-logs"
      Tier = "Security"
    }
  )
}

# IAM Role para Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.project_name}-${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-flow-logs-role"
      Tier = "Security"
    }
  )
}

# IAM Policy para Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.project_name}-${var.environment}-vpc-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ============================================================================
# DB Subnet Group - Para RDS Multi-AZ
# ============================================================================
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
      Tier = "Database"
    }
  )
}
