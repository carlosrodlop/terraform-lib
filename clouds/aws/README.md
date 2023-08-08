# AWS

<p align="center">
  <img alt="aws-icon" src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" height="100" />
</p>

---

## Configuration

- This configuration relies on defining [Environment variables to configure the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html): `AWS_PROFILE` and `AWS_DEFAULT_REGION`.

## AWS EKS Blueprints (Migration to version 5)

- [AWS EKS Blueprints](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/) is a collection of examples for common use cases of Amazon EKS which uses mainly:
  - [AWS EKS Infraestructure Modules](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
  - [AWS EKS Addons Modules](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/)
    - Before version 5, the [AWS EKS Blueprints](https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.32.1/)
  - Other AWS Modules and Resources.

## AWS Quick Start with CloudFormation

- [CloudBees CI on AWS](https://aws-quickstart.github.io/quickstart-cloudbees-ci/). NOTE: At the moment of writting this note that code do not follow latest recommendations for CloudBees CI on AWS (like using ALB instead of CLB).
