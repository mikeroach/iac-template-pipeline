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

  secondary_ranges = {
    "${var.gcp_project}-${var.gcp_region}" = []
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