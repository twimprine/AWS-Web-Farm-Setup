variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "vpc_subnet" {
  description = "Subnet of entire VPC"
}

variable "availability_zones" {
  description = "The availability zones in the selected region"
}
