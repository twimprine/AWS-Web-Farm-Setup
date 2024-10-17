variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "config_bucket_name" {
    description = "Bucket name the in whcih the ec2 config data is stored"
}

variable "private_ca_arn" {
    description = "The ARN of the ACM Private Certificate Authority"
    type        = string
}