variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
