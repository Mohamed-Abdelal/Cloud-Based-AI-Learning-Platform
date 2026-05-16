# Terraform configuration wrapper for environments
# This file is used in each environment directory

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state storage
  # backend "s3" {
  #   bucket         = "cloud-learning-platform-terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project             = "Cloud-Learning-Platform"
      Environment         = var.environment
      ManagedBy           = "Terraform"
      TerraformWorkspace  = terraform.workspace
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  environment          = var.environment
  project_name         = var.project_name
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  project_name = var.project_name
}

# S3 Buckets Module
module "s3" {
  source = "../../modules/s3"

  environment  = var.environment
  project_name = var.project_name
  enable_encryption = var.enable_encryption
}

# RDS Database Module
module "rds" {
  source = "../../modules/rds"

  environment              = var.environment
  project_name            = var.project_name
  db_instance_class       = var.db_instance_class
  db_allocated_storage    = var.db_allocated_storage
  vpc_security_group_ids  = [module.security_groups.rds_security_group_id]
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  enable_backup           = var.enable_backup
  retention_days          = var.retention_days
  multi_az                = var.enable_multi_az
  enable_encryption       = var.enable_encryption
}

# ECS Cluster Module
module "ecs" {
  source = "../../modules/ecs"

  project_name      = var.project_name
  environment       = var.environment
  enable_monitoring = var.enable_monitoring
  retention_in_days = var.retention_days
}

# Application Load Balancer Module
module "alb" {
  source = "../../modules/alb"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  ssl_certificate_arn  = var.ssl_certificate_arn
}

# EC2 Instances Module
module "ec2" {
  source = "../../modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_count        = var.instance_count
  instance_type         = var.instance_type
  ami_id                = data.aws_ami.amazon_linux.id
  subnet_ids            = module.vpc.private_subnet_ids
  security_group_ids    = [module.security_groups.app_security_group_id]
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS name for accessing the application"
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "ECS cluster name"
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  sensitive   = true
  description = "RDS database endpoint"
}

output "s3_buckets" {
  value       = module.s3.bucket_names
  description = "S3 bucket names for each service"
}
