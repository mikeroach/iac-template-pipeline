variable "dns_hostname" {
  type        = string
  description = "Third-level DNS hostname for this environment (used by dynamic DNS K8s DaemonSet and Nginx ingress controller)"
}

variable "dns_domain" {
  type        = string
  description = "Base (second level) DNS domain name for this environment (used by dynamic DNS K8s DaemonSet and Nginx ingress controller)"
}

variable "dockerhub_credentials" {
  type        = string
  description = "Base64 encoded configuration and credentials for Docker Hub container registry"
}

variable "gandi_api_key" {
  type        = string
  description = "GANDI Live DNS key used to update dynamic DNS for this environment via K8s DaemonSet"
}

variable "gcp_credentials" {
  type        = string
  description = "File path to GCP service account credentials to use when deploying this infrastructure"
}

variable "gcp_project_shortname" {
  type        = string
  description = "Short, organization-specific name of the Google Cloud Platform project that will house this infrastructure (corresponds to output from the IaC Bootstrap module)"
}

variable "gcp_organization_id" {
  type        = string
  description = "ID of the Google Cloud Platform organization hosting our Project Factory seed project"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud Platform region to house our infrastructure"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud Platform compute zone to launch our infrastructure"
}

variable "iac_bootstrap_tfstate_bucket" {
  type        = string
  description = "Globally unique name for the GCS bucket hosting IaC bootstrap Terraform remote state files (used as datasource)"
}

variable "iac_bootstrap_tfstate_prefix" {
  type        = string
  description = "Globally unique name for the GCS bucket hosting IaC bootstrap Terraform remote state files (used as datasource)"
}

variable "iac_bootstrap_tfstate_credentials" {
  type        = string
  description = "File path to GCP service account credentials with permission to access the IaC bootstrap Terraform remote state GCS bucket"
}

variable "k8s_disk_size_gb" {
  type        = string
  description = "Size of disk attached to each Kubernetes node (in GB)"
  default     = "10"
}

variable "k8s_disk_type" {
  type        = string
  description = "Type of disk attached to each Kubernetes node (standard vs. SSD)"
  default     = "pd-standard"
}

variable "k8s_initial_node_count" {
  type        = string
  description = "Number of machines to create in Kubernetes node pool"
  default     = "1"
}

variable "k8s_machine_type" {
  type        = string
  description = "Specifies the GCP machine type of Kubernetes node(s)"
  default     = "g1-small"
}

variable "k8s_preemptible" {
  type        = bool
  description = "Specifies whether Kubernetes nodes are preemptible"
  default     = true
}

variable "service_aphorismophilia_namespace" {
  type        = string
  description = "Kubernetes namespace in which to deploy the aphorismophilia service"
}

variable "service_aphorismophilia_version" {
  type        = string
  description = "Service version of aphorismophilia to deploy"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create inside the services VPC"
}