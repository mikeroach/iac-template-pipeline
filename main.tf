/* This root module manages the submodules and resources for a composed
Infrastructure as Code Template Stack. See README.md for details. */

/* Interpolating the GCP project ID directly into a data source lookup
this way requires a map output type in the upstream module. I wasn't able
to successfully concatenate the data source lookup + variable inline since
Terraform interpreted it as a string instead of variable reference. */
locals {
  project_id      = "${data.terraform_remote_state.iac_bootstrap.outputs.project_ids["${var.gcp_project_shortname}"]}"
}
provider "google" {
  version     = "2.14.0"
  credentials = "${file(var.gcp_credentials)}"
  region      = var.gcp_region
}

provider "google-beta" {
  version     = "2.14.0"
  credentials = "${file(var.gcp_credentials)}"
  region      = var.gcp_region
}

provider "null" {
  version = "2.1"
}

provider "random" {
  version = "2.2"
}

provider "kubernetes" {
  version = "1.9.0"
  /* Using basic auth avoids the need to either bundle the gcloud +
  k8s tool suites with our Jenkins instance or build a custom tools
  helper container image for now.

  I ended up baking the Google Cloud SDK into my Jenkins container
  anyway due to obnoxious local-exec helper script dependencies in
  third party registry modules. */
  host             = "https://${module.k8s-infra.k8s_endpoint}/"
  username         = module.k8s-infra.k8s_cluster_admin_user
  password         = module.k8s-infra.k8s_cluster_admin_pass
  insecure         = true
  load_config_file = false
  /* Commented out to use implicit kubectl-configured authentication.
  cluster_ca_certificate = module.k8s.k8s_cluster_ca_certificate
  client_certificate     = "${module.k8s.k8s_client_certificate}"
  client_key             = "${module.k8s.k8s_client_key}"
  */
}

/* Pull outputs from the IaC bootstrap module's state. Fortunately, this
supports interpolation (unlike the main backend configuration). See also:
https://www.terraform.io/docs/providers/terraform/d/remote_state.html */
data "terraform_remote_state" "iac_bootstrap" {
  backend = "gcs"
  config = {
    bucket      = var.iac_bootstrap_tfstate_bucket
    prefix      = var.iac_bootstrap_tfstate_prefix
    credentials = var.iac_bootstrap_tfstate_credentials
  }
}

/* Create network infrastructure in a submodule.
TODO: Break this out into a separately versioned Terraservice. */
module "network" {
  source      = "./modules/network-infra"
  gcp_project = local.project_id
  gcp_region  = var.gcp_region
  subnet_cidr = var.subnet_cidr
}

/* Create GCP Kubernetes Engine infrastructure in a submodule.
TODO: Break this out into a separately versioned Terraservice. */
module "k8s-infra" {
  source                = "./modules/k8s-infra"
  gcp_project           = local.project_id
  gcp_project_shortname = var.gcp_project_shortname
  gcp_region            = var.gcp_region
  gcp_zone              = var.gcp_zone
  disk_size_gb          = var.k8s_disk_size_gb
  disk_type             = var.k8s_disk_type
  initial_node_count    = var.k8s_initial_node_count
  machine_type          = var.k8s_machine_type
  network               = module.network.network_name
  preemptible           = var.k8s_preemptible
  subnetwork            = module.network.subnet_name
}

// Deploy configuration and applications to Kubernetes cluster.
module "k8s-apps" {
  source                            = "./modules/k8s-apps"
  dns_domain                        = var.dns_domain
  dockerhub_credentials             = var.dockerhub_credentials
  gandi_api_key                     = var.gandi_api_key
  gcp_project_shortname             = var.gcp_project_shortname
  service_aphorismophilia_version   = var.service_aphorismophilia_version
  service_aphorismophilia_namespace = var.service_aphorismophilia_namespace
}