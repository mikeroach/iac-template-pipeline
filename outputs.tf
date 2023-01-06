/*
output "k8s_client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster endpoint"
  value       = module.k8s-infra.k8s_client_certificate
}

output "k8s_client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint"
  value       = module.k8s-infra.k8s_client_key
  sensitive   = true
}

output "k8s_cluster_ca_certificate" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint"
  value       = module.k8s-infra.k8s_cluster_ca_certificate
  sensitive   = true
}
*/

output "k8s_endpoint" {
  description = "IP address of Kubernetes cluster API server endpoint"
  value       = module.k8s-infra.k8s_endpoint
}