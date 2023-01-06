resource "google_container_cluster" "k8s_cluster" {
  name                     = "${var.gcp_project_shortname}-k8s-cluster"
  location                 = var.gcp_zone
  project                  = var.gcp_project
  network                  = var.network
  subnetwork               = var.subnetwork
  remove_default_node_pool = false
  initial_node_count       = var.initial_node_count

  /* These secondary range names for VPC-native cluster addressing are
  statically defined for now - see network module for details. */
  ip_allocation_policy {
    use_ip_aliases                = true
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00" // UTC
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  /* The Terraform GCP provider recommends against using the default node pool
  since the entire cluster must be destroyed and recreated to change any of its
  parameters. I chose to use the default node pool anyway since it significantly
  reduces module development and testing cycle time (each resource can take around
  5 minutes to create AND destroy!), and I'm not yet keeping persistent data
  inside my personal project clusters.  */
  node_config {
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    preemptible  = var.preemptible
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  private_cluster_config {
    enable_private_endpoint = false
  }

}