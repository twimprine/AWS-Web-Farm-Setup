variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

# Defining our inputs
variable "vpc_id" {
  description = "ID of the VPC"
}

variable "vpc_subnet" {
  description = "Subnet of entire VPC"
}

variable "host_instance_type" {
  description = "What instance type and size to use"
}

variable "host_volume_size" {
  description = "Host Volume OS disk size"
}

variable "availability_zones" {
  description = "Availability zones in current region"
} 

variable "app_listening_port" {
  description = "Port that the app is listening on on the host"
  type        = number
}
/* 
variable "vpc_obj" {
  description = "VPC Object"
} */

# variable "private_subnets" {
#   description = "Private subnets in all AZ"
# }

variable "asg_desired_capacity" {
  description = "Initial number of worker nodes"
}

variable "asg_min_size" {
  description = "Minimum number of worker nodes"
}

variable "asg_max_size" {
  description = "Maximum number of worker nodes"
}



# variable "load_balancer_object" {
#   description = "ALB Object"
# }

# variable "load_balancer_target_group" {
#   description = "ALB Target Group"
# }

# variable "redis_cluster" {
#   description = "Redis Cluster info"
# }

# variable "redis_subnet_group" {
#   description = "Redis Subnet Group info"

# }

# variable "redis_subnets" {
#   description = "Redis Subnets info"
# }


# variable "elastic_subnets" {
#   description = "Elastic Subnets info"
# }

# variable "elastic_nodes" {
#   description = "Elastic Nodes info"
# }
