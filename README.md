# Terraform Library

<p align="center">
  <img alt="terraform-icon" src="https://icons-for-free.com/iconfiles/png/512/Terraform-1329545833434920628.png" height="160" />
  <p align="center">Welcome to my Terraform Library, a storage place for my assets related to my journey around Terraform and Iac for the Cloud.</p>
</p>

---

![GitHub Latest Release)](https://img.shields.io/github/v/release/carlosrodlop/terraform-lib?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/carlosrodlop/terraform-lib?logo=github) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets) [![terraform_checkov](https://img.shields.io/badge/protected%20by-checkov-blue)](https://github.com/bridgecrewio/checkov) [![terraform docs](https://img.shields.io/badge/docs%20by-terraformdocs-blue)](https://github.com/terraform-docs/terraform-docs/)

- It contains deployments for Kubernetes Cluster and its pre-requisites for different Cloud providers.
- It uses the [Docker Library](https://github.com/carlosrodlop/docker-lib) to make its content portable.
- The Helm provider uses the values from the [Kubernetes library](https://github.com/carlosrodlop/K8s-lib)
  - Separation of Helm provider from the Cluster Generation per [Stacking with managed Kubernetes cluster resources](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
  - It requires `git submodule update --init --recursive`
- [Pre-commits](.pre-commit-config.yaml) for Security, Validations and Documentation
- Variables inheritance. See [Terraform - Variable Precedence - Learning-Ocean](https://learning-ocean.com/tutorials/terraform/terraform-variable-precedence)
