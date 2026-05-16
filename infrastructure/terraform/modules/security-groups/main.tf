# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg-${var.environment}"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg-${var.environment}"
  }
}

# Security Group for Container Services
resource "aws_security_group" "containers" {
  name        = "${var.project_name}-containers-sg-${var.environment}"
  description = "Security group for container services"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to S3 and external services"
  }

  tags = {
    Name = "${var.project_name}-containers-sg-${var.environment}"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Security group for RDS databases"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg-${var.environment}"
  }
}

# RDS ingress rule (separate to avoid cycle)
resource "aws_security_group_rule" "rds_ingress_from_containers" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.containers.id
  security_group_id        = aws_security_group.rds.id
  description              = "PostgreSQL from containers"
}

# Security Group for Kafka
resource "aws_security_group" "kafka" {
  name        = "${var.project_name}-kafka-sg-${var.environment}"
  description = "Security group for Kafka cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kafka inter-broker"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Zookeeper"
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-kafka-sg-${var.environment}"
  }
}

# Kafka ingress from containers (separate to avoid cycle)
resource "aws_security_group_rule" "kafka_ingress_from_containers" {
  type                     = "ingress"
  from_port                = 9092
  to_port                  = 9092
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.containers.id
  security_group_id        = aws_security_group.kafka.id
  description              = "Kafka from containers"
}

# Security Group for Lambda
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg-${var.environment}"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to S3 and external services"
  }

  tags = {
    Name = "${var.project_name}-lambda-sg-${var.environment}"
  }
}

# Lambda egress to Kafka (separate to avoid cycle)
resource "aws_security_group_rule" "lambda_egress_to_kafka" {
  type                     = "egress"
  from_port                = 9092
  to_port                  = 9092
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kafka.id
  security_group_id        = aws_security_group.lambda.id
  description              = "Kafka"
}

# Container egress to RDS (separate to avoid cycle)
resource "aws_security_group_rule" "containers_egress_to_rds" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.containers.id
  description              = "PostgreSQL to RDS"
}

# Container egress to Kafka (separate to avoid cycle)
resource "aws_security_group_rule" "containers_egress_to_kafka" {
  type                     = "egress"
  from_port                = 9092
  to_port                  = 9092
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kafka.id
  security_group_id        = aws_security_group.containers.id
  description              = "Kafka"
}

# Security Group for EC2 SSH (for management)
resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh-sg-${var.environment}"
  description = "Security group for SSH access to EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Only from VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ssh-sg-${var.environment}"
  }
}

# Outputs
output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "containers_sg_id" {
  value = aws_security_group.containers.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "kafka_sg_id" {
  value = aws_security_group.kafka.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "ssh_sg_id" {
  value = aws_security_group.ssh.id
}

