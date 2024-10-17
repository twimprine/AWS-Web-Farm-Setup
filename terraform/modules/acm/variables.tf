variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "dns_zone" {
  description = "The zone of your domain"
  type        = string
}

variable "dns_zone_id" {
  description = "The zone id of your domain"
  type        = string
}

variable "aws_region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-east-1"
}

