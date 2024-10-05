variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to state resources"
  type        = map(string)
}