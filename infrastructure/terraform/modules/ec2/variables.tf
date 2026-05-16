variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "kafka_subnets" {
  description = "Kafka subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups object"
  type = object({
    containers_sg_id = string
    kafka_sg_id      = string
    ssh_sg_id        = string
  })
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "kafka_instance_type" {
  description = "Kafka broker instance type"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "Minimum size for ASG"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum size for ASG"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 3
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloud-learning-platform"
}

