variable "tags" {
    description = "Project Tags"
    type        = map(string)
}

variable "region" {
    description = "AWS Region for Route53"
    type        = string
}

variable "root_zone_id" {
    description = "The Route 53 zone ID for the root domain"
    type        = string
}

variable "root_domain" {
    description = "The root domain name (e.g. example.com)"
    type        = string
}
