# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group-${var.environment}"
  subnet_ids = var.data_subnets

  tags = {
    Name = "${var.project_name}-db-subnet-group-${var.environment}"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "postgresql" {
  name   = "${var.project_name}-postgresql-${var.environment}"
  family = "postgres16"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.project_name}-postgresql-params-${var.environment}"
  }
}

# User Management Database
resource "aws_db_instance" "user_management" {
  identifier             = "${var.project_name}-user-mgmt-db-${var.environment}"
  engine                 = "postgres"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  storage_encrypted       = true

  db_name  = "usermanagement"
  username = "dbadmin"
  password = var.db_password

  vpc_security_group_ids = [var.security_groups.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  # Use default parameter group to avoid engine family mismatches
  # parameter_group_name   = aws_db_parameter_group.postgresql.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.project_name}-user-mgmt-final-${var.environment}"

  tags = {
    Name        = "${var.project_name}-user-mgmt-db-${var.environment}"
    Service     = "user-management"
    Environment = var.environment
  }
}

# Chat Service Database
resource "aws_db_instance" "chat_service" {
  identifier             = "${var.project_name}-chat-db-${var.environment}"
  engine                 = "postgres"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  storage_encrypted       = true

  db_name  = "chatservice"
  username = "dbadmin"
  password = var.db_password

  vpc_security_group_ids = [var.security_groups.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  # parameter_group_name   = aws_db_parameter_group.postgresql.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.project_name}-chat-final-${var.environment}"

  tags = {
    Name        = "${var.project_name}-chat-db-${var.environment}"
    Service     = "chat-service"
    Environment = var.environment
  }
}

# Document Reader Service Database
resource "aws_db_instance" "document_service" {
  identifier             = "${var.project_name}-document-db-${var.environment}"
  engine                 = "postgres"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  storage_encrypted       = true

  db_name  = "documentservice"
  username = "dbadmin"
  password = var.db_password

  vpc_security_group_ids = [var.security_groups.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  # parameter_group_name   = aws_db_parameter_group.postgresql.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.project_name}-document-final-${var.environment}"

  tags = {
    Name        = "${var.project_name}-document-db-${var.environment}"
    Service     = "document-service"
    Environment = var.environment
  }
}

# Quiz Service Database
resource "aws_db_instance" "quiz_service" {
  identifier             = "${var.project_name}-quiz-db-${var.environment}"
  engine                 = "postgres"
  instance_class         = var.rds_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  storage_encrypted       = true

  db_name  = "quizservice"
  username = "dbadmin"
  password = var.db_password

  vpc_security_group_ids = [var.security_groups.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  # parameter_group_name   = aws_db_parameter_group.postgresql.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.project_name}-quiz-final-${var.environment}"

  tags = {
    Name        = "${var.project_name}-quiz-db-${var.environment}"
    Service     = "quiz-service"
    Environment = var.environment
  }
}

# Outputs
output "endpoints" {
  value = {
    user_management = aws_db_instance.user_management.endpoint
    chat_service    = aws_db_instance.chat_service.endpoint
    document_service = aws_db_instance.document_service.endpoint
    quiz_service    = aws_db_instance.quiz_service.endpoint
  }
  sensitive = true
}

