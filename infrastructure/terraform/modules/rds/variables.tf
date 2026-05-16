variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "data_subnets" {
  description = "Data subnet IDs for RDS"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups object"
  type = object({
    rds_sg_id = string
  })
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloud-learning-platform"
}

