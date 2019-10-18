variable "gcp_project" {
  type        = string
  description = "ID of the Google Cloud Platform project in which to build this infrastructure"
}

variable "gcp_project_shortname" {
  type        = string
  description = "Short, organization-specific name of the Google Cloud Platform project that will house this infrastructure (corresponds to output from the IaC Bootstrap module)"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud Platform region to house our infrastructure"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud Platform compute zone in which to build this Kubernetes cluster"
}

variable "disk_size_gb" {
  type        = string
  description = "Size of disk attached to each Kubernetes node (in GB)"
  default     = "10"
}

variable "disk_type" {
  type        = string
  description = "Type of disk attached to each Kubernetes node (standard vs. SSD)"
  default     = "pd-standard"
}

variable "initial_node_count" {
  type        = string
  description = "Number of machines to create in Kubernetes node pool"
  default     = "1"
}

variable "machine_type" {
  type        = string
  description = "Specifies the GCP machine type of Kubernetes node(s)"
  default     = "g1-small"
}

variable "network" {
  type        = string
  description = "Name of the service VPC in which to create the Kubernetes cluster"
}

variable "preemptible" {
  type        = bool
  description = "Specifies whether Kubernetes nodes are preemptible"
  default     = true
}

variable "subnetwork" {
  type        = string
  description = "Name of the service subnet in which to create the Kubernetes cluster"
}