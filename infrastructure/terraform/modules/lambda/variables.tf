variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups object"
  type = object({
    lambda_sg_id = string
  })
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_buckets" {
  description = "S3 buckets object"
  type = object({
    tts_service      = string
    stt_service     = string
    chat_service    = string
    document_service = string
    quiz_service    = string
  })
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloud-learning-platform"
}

