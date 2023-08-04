# Terraform Library

<p align="center">
  <img alt="terraform-icon" src="https://icons-for-free.com/iconfiles/png/512/Terraform-1329545833434920628.png" height="160" />
  <p align="center">Welcome to my Terraform Library, a storage place for my assets related to my journey around Terraform and Iac for the Cloud.</p>
</p>

---

![GitHub Latest Release)](https://img.shields.io/github/v/release/carlosrodlop/terraform-lib?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/carlosrodlop/terraform-lib?logo=github) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets) [![terraform_checkov](https://img.shields.io/badge/protected%20by-checkov-blue)](https://github.com/bridgecrewio/checkov) [![terraform docs](https://img.shields.io/badge/docs%20by-terraformdocs-blue)](https://github.com/terraform-docs/terraform-docs/) [![mdLinkChecker](https://github.com/carlosrodlop/terraform-lib/actions/workflows/mdLinkChecker.yml/badge.svg)](https://github.com/carlosrodlop/terraform-lib/actions/workflows/mdLinkChecker.yml)

| [Documentation](https://github.com/carlosrodlop/carlosrodlop-docs/tree/main/hashicorp) | [References](https://github.com/carlosrodlop/carlosrodlop-docs#terraform) |
| -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |

- It contains deployments and configuration for Kubernetes Cluster and companion infrastructure for different Cloud providers.
- Terraform operations use makefile inside every cloud provider (e.g. `aws`) to give you examples of the most common operation command set. There are targets for the most common scenarios: init (with backend), plan/apply and destroy but also a general action target to run any terraform command.
  - Copy `.env.example` to `.env` to customize the environment variables. Although, some variables can be passed as arguments to target in the make command (`ROOT` for example).
- Values Customization:
  - Variables: Copy `.auto.tfvars.example` to `.auto.tfvars` inside the root folders and replace it with your values. It relies on Variables inheritance. See [Terraform - Variable Precedence - Learning-Ocean](https://learning-ocean.com/tutorials/terraform/terraform-variable-precedence)
  - Backend:
    1. Apply the Root `state-bucket` creates a remote backend
    2. Copy `backend.tf.example` to `backend.tf` in every Root to use the backend created in the previous step.
- Companion Repositories:
  - [Docker Library](https://github.com/carlosrodlop/docker-lib) for testing using the image
  - The Helm provider uses the values from the [Kubernetes library](https://github.com/carlosrodlop/K8s-lib)
    - ⚠️ IMPORTANT - It requires `git submodule update --init --recursive`
    - Helm provider is separated from the creation of the K8s cluster [Stacking with managed Kubernetes cluster resources](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
- It uses [Pre-commits](.pre-commit-config.yaml) for Validations and Documentation
