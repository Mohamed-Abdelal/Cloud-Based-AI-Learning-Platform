terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Using local backend for now (can configure S3 backend later)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cloud-learning-platform/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Cloud-Learning-Platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  environment          = var.environment
  project_name         = var.project_name
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id     = module.vpc.vpc_id
  environment = var.environment
}

# S3 Buckets Module
module "s3" {
  source = "./modules/s3"
  
  environment = var.environment
  project_name = var.project_name
}

# EC2 Instances Module
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnet_ids
  private_subnets     = module.vpc.private_subnet_ids
  kafka_subnets       = module.vpc.kafka_subnet_ids
  security_groups     = module.security_groups
  environment         = var.environment
  key_name           = var.key_name
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id              = module.vpc.vpc_id
  data_subnets        = module.vpc.data_subnet_ids
  security_groups     = module.security_groups
  environment         = var.environment
  db_password         = var.db_password
}

# Lambda Module - Commented out due to IAM access restrictions
# module "lambda" {
#   source = "./modules/lambda"
#   
#   vpc_id              = module.vpc.vpc_id
#   private_subnets     = module.vpc.private_subnet_ids
#   security_groups     = module.security_groups
#   environment         = var.environment
#   s3_buckets          = module.s3.bucket_names
# }

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"
  
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnet_ids
  security_groups     = module.security_groups
  environment         = var.environment
}

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "s3_buckets" {
  value = module.s3.bucket_names
}

output "rds_endpoints" {
  value = module.rds.endpoints
  sensitive = true
}

output "load_balancer_dns" {
  value = module.load_balancer.dns_name
}

