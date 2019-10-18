// TODO: Implement this as a generic, independently versioned firewall rule module.

/* Unfortunately GCP doesn't support specifying ICMP type in firewall rules. I only
want to allow TTL exceeded, fragmentation needed but DF set, and redirects but must
instead enable the entire ICMP family to avoid breaking legitimate connectivity. */
resource "google_compute_firewall" "allow-all-icmp" {
  name          = "allow-all-icmp"
  description   = "Allow ICMP from anywhere (restrict type upon GCP support!)"
  project       = var.gcp_project
  network       = var.network
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

// Allow all web traffic from external networks.
resource "google_compute_firewall" "allow-external-web-traffic" {
  name          = "allow-external-web-traffic"
  description   = "Allow external web traffic"
  project       = var.gcp_project
  network       = var.network
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}