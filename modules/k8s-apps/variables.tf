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

variable "gcp_project_shortname" {
  type        = string
  description = "Short, organization-specific name of the Google Cloud Platform project that will house this infrastructure (corresponds to output from the IaC Bootstrap module)"
}

variable "service_aphorismophilia_namespace" {
  type        = string
  description = "Kubernetes namespace in which to deploy the aphorismophilia service"
}

variable "service_aphorismophilia_version" {
  type        = string
  description = "Service version of aphorismophilia to deploy"
}