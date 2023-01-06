module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "1.1.0"
  project_id                             = var.gcp_project
  network_name                           = "${var.gcp_project}-vpc"
  shared_vpc_host                        = false
  routing_mode                           = "REGIONAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name           = "${var.gcp_project}-${var.gcp_region}"
      subnet_ip             = var.subnet_cidr
      subnet_region         = var.gcp_region
      subnet_private_access = true
      subnet_flow_logs      = false
    },
  ]

  /* Pending Google TF provider upgrade, statically define local Pod and Service
  ranges here to simplify VPC-native cluster creation after GKE API defaults change.
  See https://github.com/hashicorp/terraform-provider-google/pull/10686 and
  https://github.com/hashicorp/terraform-provider-google/blob/ca1908a68df66fb6f500a659ce873cf82b5cd37e/CHANGELOG.md?plain=1#L1001
  */
  secondary_ranges = {
    "${var.gcp_project}-${var.gcp_region}" = [
      {
        range_name    = "pods"
        ip_cidr_range = "192.168.0.0/20"
      },
      {
        range_name    = "services"
        ip_cidr_range = "172.16.0.0/20"
      }
    ]
  }

  routes = [
    {
      name              = "default-internet-route"
      description       = "Default route to the Internet."
      destination_range = "0.0.0.0/0"
      next_hop_internet = true
      priority          = "1000"
    }
  ]

}

module "firewall" {
  source      = "./gcp-firewall"
  gcp_project = var.gcp_project
  network     = module.vpc.network_name
}