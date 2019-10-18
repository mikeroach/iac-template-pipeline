variable "gcp_project" {
  type        = string
  description = "Google Cloud Platform project in which to build this infrastructure"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud Platform region to house our infrastructure"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR of the single subnet to create in VPC"
}
