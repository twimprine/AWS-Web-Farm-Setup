variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
}