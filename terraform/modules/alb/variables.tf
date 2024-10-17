variable "alb_idle_timeout" {
  description = "ALB Idle Timeout"
  type        = number
  default     = 60
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "external_certificate_arn" {
  description = "ACM Certificate ARN"
}

variable "hosts_app_listening_port" {
  description = "Port that the app is listening on"
  type        = number
}

variable "private_subnets" {
  description = "Private Subnets in all AZ"
}

variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
}
