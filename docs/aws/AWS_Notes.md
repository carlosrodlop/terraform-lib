# AWS Notes

## Troubleshooting

### EKS ALB Load Balancer

Kubectl Pods

- External DNS, once it is deployed, it would be correctly working for `HostName` `ci.example.com` when `kubectl logs external-dns-*`

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
