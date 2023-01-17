# EKS LABS

## Principles

- Deploy anything on the top of [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
  - It focuses more on the deployment and configuration of your target application and 3rd party integrations. It focuses less on the deployment of EKS, its add-ons and well-known cloud applications.
- Shift-left for Security and Terraform validations
  - Validate EKS security [aws-samples/hardeneks: Runs checks to see if an EKS cluster follows EKS Best Practices.](https://github.com/aws-samples/hardeneks)

### Bookmarks

- [EKS Blueprints outputs](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/outputs.tf)
- [EKS Examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples)

## Shared

It contains resources shared among labs including

- Terraform Modules e.g. State Backend in S3
- Variables. See [Terraform - Variable Precedence - Learning-Ocean](https://learning-ocean.com/tutorials/terraform/terraform-variable-precedence)
- Secrets managed as [Kubernetes Secrets](https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/secrets.adoc#kubernetes-secrets) and mounted in the `SECRET` path of the container.
- CloudBees Configuration as Code
  - Controllers: [carlosrodlop/cb-casc-controllers](https://github.com/carlosrodlop/cb-casc-controllers)
  - Operation Center: [carlosrodlop/cb-casc-oc](https://github.com/carlosrodlop/cb-casc-oc)

### Target Applications

#### CloudBees

- [CloudBees CI Docs](https://docs.cloudbees.com/docs/cloudbees-ci/latest/)
- [CloudBees CI release notes | CloudBees Docs](https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-ci/)

##### Network Troubleshooting

Kubectl Pods

- External DNS, once it is deployed, it would be correctly working for `HostName` ci.example.com :

```sh
time="2023-01-15T13:56:06Z" level=info msg="All records are already up to date"
time="2023-01-15T13:57:07Z" level=info msg="Applying provider record filter for domains: [ci.example.com. .ci.example.com.]"
time="2023-01-15T13:57:07Z" level=info msg="Desired change: CREATE ci.example.com A [Id: /hostedzone/Z04178721B8NPCSMWT4K0]"
time="2023-01-15T13:57:07Z" level=info msg="Desired change: CREATE ci.example.com TXT [Id: /hostedzone/Z04178721B8NPCSMWT4K0]"
time="2023-01-15T13:57:07Z" level=info msg="Desired change: CREATE cname-ci.example.com TXT [Id: /hostedzone/Z04178721B8NPCSMWT4K0]"
time="2023-01-15T13:57:07Z" level=info msg="3 record(s) in zone example.com. [Id: /hostedzone/Z04178721B8NPCSMWT4K0] were successfully updated"
```

- AWS Load Balancer

AWS Console

- Certified Manager (CM)
- ALB Controller
- Route 53

## References

- [Amazon EKS Blueprints for Terraform](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- [Amazon EKS Workshop :: Amazon EKS Workshop](https://www.eksworkshop.com/)
- [Artifact Hub](https://artifacthub.io/)
