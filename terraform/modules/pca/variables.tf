variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "key_algorithm" {
  description = "The algorithm used to generate the key pair"
  type        = string
}

variable "signing_algorithm" {
  description = "The algorithm used to sign the certificate"
  type        = string
}

variable "common_name" {
  description = "The common name of the certificate"
  type        = string
}

variable "country" {
  description = "The country of the certificate"
  type        = string

}

variable "locality" {
  description = "The locality of the certificate"
  type        = string
}

variable "organization" {
  description = "The organization of the certificate"
  type        = string
}

variable "organizational_unit" {
  description = "The organizational unit of the certificate"
  type        = string
}

variable "state" {
  description = "The state of the certificate"
  type        = string
}

variable "certificate_validity_length" {
  description = "The number of <timeperiod> the certificate is valid for"
  type        = number
}

variable "certificate_validity_timeperiod" {
  description = "The time period the certificate is valid for (DAYS, MONTHS, YEARS, ABSOLUTE, END_DATE)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}