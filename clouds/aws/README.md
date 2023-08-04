# AWS

<p align="center">
  <img alt="aws-icon" src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" height="100" />
</p>

---

## Configuration

- This configuration relies on defining [Environment variables to configure the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html): `AWS_PROFILE` and `AWS_DEFAULT_REGION`.

## EKS

- Deploy anything on the top of [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
  - Using ![version](https://img.shields.io/badge/version-v4.32.1-blue)
  - It focuses more on the deployment and configuration of your target application and 3rd party integrations. It focuses less on the deployment of EKS, its add-ons and well-known cloud applications.

### Bookmarks

- [EKS Blueprints outputs](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/outputs.tf)
- [EKS Examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples)
