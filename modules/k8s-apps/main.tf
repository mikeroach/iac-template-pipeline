/* I dislike nesting the modules this deep, however this makes it simpler to handle
dependency management from the root module during create/destroy test cycles when
composing an entire infrastructure stack into one state. Revisit once Terraform
modules support depends_on per https://github.com/hashicorp/terraform/issues/10462 .*/
module "k8s-config" {
  source                = "./k8s-config"
  dns_domain            = var.dns_domain
  gandi_api_key         = var.gandi_api_key
  gcp_project_shortname = var.gcp_project_shortname
}

module "service-aphorismophilia" {
  source                            = "github.com/mikeroach/aphorismophilia-terraform?ref=v17"
  dns_domain                        = var.dns_domain
  dns_hostname                      = var.gcp_project_shortname
  dockerhub_credentials             = var.dockerhub_credentials
  service_aphorismophilia_namespace = var.service_aphorismophilia_namespace
  service_aphorismophilia_version   = var.service_aphorismophilia_version
}