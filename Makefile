#terraform-cmd = docker run -i -e "TF_IN_AUTOMATION=1" -w /data --rm -v ${CURDIR}:/data hashicorp/terraform:0.12.6
terraform-cmd = TF_IN_AUTOMATION=1 terraform

TFVARS ?= "./secrets/tfdev.tfvars"

# Extract variables from Terraform environment
PROJECT_NAME := ${shell awk -F = '/^gcp_project_shortname/{gsub(/[ |\"]/, ""); print $$2}' $(TFVARS) }
DOMAIN := ${shell awk -F = '/^dns_domain/{gsub(/[ |\"]/, ""); print $$2}' $(TFVARS) }
GANDI_API_KEY := ${shell awk -F = '/^gandi_api_key/{gsub(/[ |\"]/, ""); print $$2}' $(TFVARS) }

VARS = -var-file=$(TFVARS)
#BACKEND = -backend-config=../secrets/backend.tfvars

test: tf-init tf-fmt tf-validate

# Instantiate a new environment from scratch.
environment: tf-init tf-plan network k8s apps

plan: tf-plan

apply: tf-apply

destroy:
	$(terraform-cmd) destroy -auto-approve $(VARS) -target=module.k8s-apps
	$(terraform-cmd) destroy -auto-approve $(VARS) -target=module.k8s-infra
	$(terraform-cmd) destroy -auto-approve $(VARS) -target=module.network
	# Quicker to just leave the stale DNS record when destroying ephemeral environments;
	# Gandi returns cache TTL of 1h for NXDOMAIN responses but 5m for A record response.
	#curl -X DELETE -H "Content-Type: application/json" -H "X-Api-Key: $(GANDI_API_KEY)" https://dns.api.gandi.net/api/v5/domains/$(DOMAIN)/records/$(PROJECT_NAME)/A
	rm -f terraform.tfstate terraform.tfstate.backup

tf-init:
	$(terraform-cmd) init -input=false $(VARS) #$(BACKEND)

tf-fmt:
	$(terraform-cmd) fmt -check -recursive -diff

#tf-lint: Revisit once this can recurse into module directories.
#	docker run -it --rm -w /data -v ${CURDIR}:/data wata727/tflint

tf-validate:
	$(terraform-cmd) validate $(VARS)

tf-plan:
	$(terraform-cmd) plan -input=false $(VARS)

tf-apply:
	$(terraform-cmd) apply -auto-approve $(VARS)

network:
	$(terraform-cmd) apply -auto-approve $(VARS) -target=module.network

k8s:
	$(terraform-cmd) apply -auto-approve $(VARS) -target=module.k8s-infra

apps:
	$(terraform-cmd) apply -auto-approve $(VARS) -target=module.k8s-apps

http-host:
	echo ${PROJECT_NAME}.${DOMAIN}