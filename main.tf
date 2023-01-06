/* This root module manages the submodules and resources for a composed
Infrastructure as Code Template Stack. See README.md for details. */

/* Interpolating the GCP project ID directly into a data source lookup
this way requires a map output type in the upstream module. I wasn't able
to successfully concatenate the data source lookup + variable inline since
Terraform interpreted it as a string instead of variable reference. */
locals {
  project_id      = "${data.terraform_remote_state.iac_bootstrap.outputs.project_ids["${var.gcp_project_shortname}"]}"
  service_account = jsondecode(file(var.gcp_credentials)).client_email
}

/* TODO: Rewrite provider definitions as required_providers so we can define
or override provider versions in per-environment module instantiation. */

provider "google" {
  version     = "2.14.0"
  credentials = file(var.gcp_credentials)
  region      = var.gcp_region
}

provider "google-beta" {
  version     = "2.14.0"
  credentials = file(var.gcp_credentials)
  region      = var.gcp_region
}

provider "null" {
  version = "2.1"
}

provider "random" {
  version = "2.2"
}

/* FIXME: Migrate each environment to use project-specific service
account for authentication to Google provider with IAM managed via
Terraform. In the meantime, this depends on org-wide permissions
imperatively granted to the Project Factory Seed Service account
outside of Terraform (this happens in upstream for other privileges
via local-exec provisioner):

gcloud organizations add-iam-policy-binding ${ORG_ID} --member="serviceAccount:${SA_ID}" --role="roles/iam.serviceAccountTokenCreator"
*/

data "google_service_account_access_token" "cluster_access_sa" {
  target_service_account = local.service_account
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s"
}

provider "kubernetes" {
  version = "1.9.0"
  /* Using token-based auth via service account requires the Google
  Cloud SDK available to our Jenkins instance, which we install
  anyway due to obnoxious local-exec helper script dependencies in
  third party registry modules. */
  host                   = "https://${module.k8s-infra.k8s_endpoint}/"
  load_config_file       = false
  token                  = data.google_service_account_access_token.cluster_access_sa.access_token
  cluster_ca_certificate = base64decode("${module.k8s-infra.k8s_cluster_ca_certificate}")

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