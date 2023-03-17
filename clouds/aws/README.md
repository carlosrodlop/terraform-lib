# AWS

![version](https://img.shields.io/badge/version-v4.20.0-blue)

NOTE: Potential Breaking Changes in Version 5

## Principles

- Deploy anything on the top of [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
  - It focuses more on the deployment and configuration of your target application and 3rd party integrations. It focuses less on the deployment of EKS, its add-ons and well-known cloud applications.
- EKS security validation by using [aws-samples/hardeneks: Runs checks to see if an EKS cluster follows EKS Best Practices.](https://github.com/aws-samples/hardeneks)
- [Pre-commits](.pre-commit-config.yaml) for Security, Validations and Documentation
- Separation of Helm provider from the Cluster Generation per [Docs overview | hashicorp/kubernetes | Stacking with managed Kubernetes cluster resources](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources)
- Variables inheritance. See [Terraform - Variable Precedence - Learning-Ocean](https://learning-ocean.com/tutorials/terraform/terraform-variable-precedence)

### Bookmarks

- [EKS Blueprints outputs](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/outputs.tf)
- [EKS Examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples)

## References

- [Awesome AWS/EKS Repos](https://github.com/stars/carlosrodlop/lists/aws-eks)
- [EKS Best Practices Guides](https://aws.github.io/aws-eks-best-practices/)
- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Amazon EKS Workshop :: Amazon EKS Workshop](https://www.eksworkshop.com/)
- [Digital Cloud AWS Cheat Sheets](https://digitalcloud.training/aws-cheat-sheets/)
- [IAM Policy Simulator](https://policysim.aws.amazon.com/home/index.jsp?#)
