output "network_name" {
  description = "Name of the VPC created in service project"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "Name of the subnet created in service VPC"
  value       = module.vpc.subnets_names.0
}

/* We don't use these after all since the GKE cluster module uses (currently)
harcoded secondary range names instead of CIDRs, but I'll leave it as a handy
reference for returning specific values from a map or list of maps based on a
different key. */
output "pod_net_cidr" {
  description = "CIDR of the secondary range within service subnet created for Pod IPs"
  value = join("", [for range in module.vpc.subnets_secondary_ranges.0 :
    range.ip_cidr_range if range.range_name == "pods"
  ])
}

output "svc_net_cidr" {
  description = "CIDR of the secondary range within service subnet created for Service IPs"
  value = join("", [for range in module.vpc.subnets_secondary_ranges.0 :
    range.ip_cidr_range if range.range_name == "services"
  ])
}