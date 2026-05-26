# ============================================================================
# Application Load Balancer
# Distribuição de tráfego, SSL/TLS termination, health checks
# ============================================================================

# ============================================================================
# Application Load Balancer
# ============================================================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
      Tier = "Compute"
    }
  )
}

# ============================================================================
# Target Group
# Registra ECS tasks como targets
# ============================================================================
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Para Fargate

  # Health Check
  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-299"
  }

  # Deregistration delay
  deregistration_delay = var.deregistration_delay

  # Stickiness (opcional - sessões pegajosas)
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 24 horas
    enabled         = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-target-group"
      Tier = "Compute"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# HTTP Listener (porta 80)
# Redirect para HTTPS
# ============================================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-http-listener",
      Tier = "Compute"
    }
  )
}

# ============================================================================
# HTTPS Listener (porta 443)
# Para desenvolvimento, usa HTTP no backend (SSL termination no ALB)
# ============================================================================
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTP" # Temporário - mudará para HTTPS quando tiver certificado

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-https-listener"
      Tier = "Compute"
    }
  )
}

# ============================================================================
# NOTA: Para produção, adicionar certificado SSL/TLS
# ============================================================================
# Descomentar quando tiver certificado ACM:
#
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = aws_acm_certificate.main.arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }
