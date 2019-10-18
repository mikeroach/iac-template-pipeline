variable "gcp_project" {
  type        = string
  description = "Google Cloud Platform project containing VPC in which to manage firewall rules"
}

variable "network" {
  type        = string
  description = "VPC network whose firewall rules are managed by this module"
}