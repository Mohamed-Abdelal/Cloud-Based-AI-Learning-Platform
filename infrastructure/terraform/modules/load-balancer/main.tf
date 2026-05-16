# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_groups.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.environment == "prod" ? true : false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${var.project_name}-alb-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for API Gateway
resource "aws_lb_target_group" "api_gateway" {
  name     = "clp-api-gw-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-api-gateway-tg-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for TTS Service
resource "aws_lb_target_group" "tts_service" {
  name     = "clp-tts-svc-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-tts-service-tg-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for STT Service
resource "aws_lb_target_group" "stt_service" {
  name     = "clp-stt-svc-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-stt-service-tg-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for Chat Service
resource "aws_lb_target_group" "chat_service" {
  name     = "clp-chat-svc-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-chat-service-tg-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for Document Service
resource "aws_lb_target_group" "document_service" {
  name     = "clp-doc-svc-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-document-service-tg-${var.environment}"
    Environment = var.environment
  }
}

# Target Group for Quiz Service
resource "aws_lb_target_group" "quiz_service" {
  name     = "clp-quiz-svc-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-quiz-service-tg-${var.environment}"
    Environment = var.environment
  }
}

# ALB Listener (HTTP - redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB Listener (HTTPS) - Commented out as certificate is required
# Uncomment and provide certificate_arn when SSL certificate is available
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.certificate_arn # Should be created via ACM
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api_gateway.arn
#   }
# }

# Listener Rules for routing - Commented out as HTTPS listener is disabled
# Uncomment when HTTPS listener is enabled
# resource "aws_lb_listener_rule" "tts_service" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 100
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tts_service.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/tts/*"]
#     }
#   }
# }
#
# resource "aws_lb_listener_rule" "stt_service" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 200
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.stt_service.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/stt/*"]
#     }
#   }
# }
#
# resource "aws_lb_listener_rule" "chat_service" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 300
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.chat_service.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/chat/*"]
#     }
#   }
# }
#
# resource "aws_lb_listener_rule" "document_service" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 400
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.document_service.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/documents/*"]
#     }
#   }
# }
#
# resource "aws_lb_listener_rule" "quiz_service" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 500
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.quiz_service.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/quiz/*"]
#     }
#   }
# }

# Outputs
output "dns_name" {
  value = aws_lb.main.dns_name
}

output "arn" {
  value = aws_lb.main.arn
}

output "target_group_arns" {
  value = {
    api_gateway    = aws_lb_target_group.api_gateway.arn
    tts_service    = aws_lb_target_group.tts_service.arn
    stt_service    = aws_lb_target_group.stt_service.arn
    chat_service   = aws_lb_target_group.chat_service.arn
    document_service = aws_lb_target_group.document_service.arn
    quiz_service   = aws_lb_target_group.quiz_service.arn
  }
}

