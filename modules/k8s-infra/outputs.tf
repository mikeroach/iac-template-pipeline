output "k8s_client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster endpoint"
  value       = google_container_cluster.k8s_cluster.master_auth.0.client_certificate
}

output "k8s_client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint"
  value       = google_container_cluster.k8s_cluster.master_auth.0.client_key
  sensitive   = true
}

output "k8s_cluster_admin_user" {
  description = "Randomly generated basic authentication username to manage new cluster via Terraform K8s provider"
  value       = random_string.k8s_cluster_admin_user.result
  sensitive   = true
}

output "k8s_cluster_admin_pass" {
  description = "Randomly generated basic authentication password to manage new cluster via Terraform K8s provider"
  value       = random_password.k8s_cluster_admin_pass.result
  sensitive   = true
}

output "k8s_cluster_ca_certificate" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint"
  value       = google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate
}

output "k8s_endpoint" {
  description = "IP address of Kubernetes cluster master"
  value       = google_container_cluster.k8s_cluster.endpoint
}