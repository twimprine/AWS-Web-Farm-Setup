variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "pca_arn" {
  description = "Private CA ARN"
  type        = string
}


variable "pca" {
  description = "Private Certificate Authority attributes"
  type = object({
    key_algorithm    = string
    signing_algorithm = string
    certificate_validity_length = number
    certificate_validity_timeperiod = string
    subject = object({
      common_name        = string
      country            = string
      locality           = string
      organization       = string
      organizational_unit = string
      state              = string
    })
  })
}