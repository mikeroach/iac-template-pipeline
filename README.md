# IaC Environment Template Pipeline

***"Consistency is the foundation of virtue." --Sir Francis Bacon***

This repository contains Terraform modules that describe a complete stack of applications and their required infrastructure dependencies as a versioned template. The template is deployed to manage multiple environments via continuous infrastructure delivery pipelines, the idea being that we can safely make changes with high confidence that what we test in prerelease will work the same way everywhere else - especially for customers in production.

It is composed of third-party modules from the [Terraform Registry](https://registry.terraform.io) and the organization-specific [Aphorismophilia module](https://github.com/mikeroach/aphorismophilia-terraform) developed in a "Terraservice-Lite" pattern.

I was inspired to experiment with this approach by Kief Morris' [Template Stack Pattern](https://infrastructure-as-code.com/patterns/stack-replication/template-stack.html) as described in [Infrastructure as Code](https://infrastructure-as-code.com) and Nicki Watt's [Terraservices presentation slides](https://www.slideshare.net/opencredo/hashidays-london-2017-evolving-your-infrastructure-with-terraform-by-nicki-watt) and [video](https://www.youtube.com/watch?v=wgzgVm7Sqlk).

#### Consumers

* Downstream IaC environment deployment pipelines [auto](https://github.com/mikeroach/iac-pipeline-auto) and [gated](https://github.com/mikeroach/iac-pipeline-gated) specify a version of this module and environment-specific input variables for application versions (and someday, resource sizing).
* Application build pipelines could launch fully production-consistent ephemeral environments from this template for integration testing, but currently they just use an ephemeral namespace in the [auto environment K8s cluster](https://github.com/mikeroach/iac-pipeline-auto) because I don't want to spend that kind of time and money on personal project pipeline builds (at least while my application dependencies still fit inside a Kubernetes namespace).

#### Development Workflow

1. IaC engineer develops and tests locally in feature branch.
1. IaC engineer commits feature branch and submits pull request.
1. Jenkins examines pull request, runs Terraform validation tests, then merges into `main` upon success. **Note this test suite is only abbreviated in feature branch/PRs to save time for this learning project - remember to run full tests during PR/branch builds in real use cases to keep `main` stable.**
1. Jenkins examines `main` branch, repeats validation tests, builds described infrastructure, runs integration tests, destroys test infrastructure, and tags new release upon success.
1. Service and environment owners update their ephemeral pipelines and persistent definitions with new version tag.