output "network_name" {
  description = "Name of the VPC created in service project"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "Name of the subnet created in service VPC"
  value       = module.vpc.subnets_names.0
}