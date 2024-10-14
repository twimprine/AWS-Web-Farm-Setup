variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "config_bucket_name" {
    description = "Bucket name the in whcih the ec2 config data is stored"
}