## Contents

```
├── aws-terraform-hybrid-dns
│   ├── README.md
│   ├── global
│   │   └── iam
│   │       ├── backend.tf
│   │       ├── provider.tf
│   │       ├── roles.tf
│   │       ├── s3.tf
│   ├── us-east-1
│   │   ├── backend.tf
│   │   ├── ec2.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── route53.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   └── us-east-2
│       ├── awszone.forward
│       ├── backend.tf
│       ├── ec2.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── vpc.tf
└── scripts
    ├── aws-describe-instance-ipaddr.sh
    ├── dxgw-prefix-add-delete.sh
    └── dxgw-prefix-checkouts.sh
```

- `/aws-terraform-hybrid-dns` contains the terraform artifacts to deploy the infrastructure for an AWS Hybrid DNS setup simulating DirectConnect connectivity to an on prem data center. Link to runbook instructions [here](https://jksprattler.github.io/jennas-runbooks/AWS/aws-tf-hybrid-dns.html) which includes a YouTube demo of the deployment.
- `/scripts` contains scripts for capturing and implementing AWS network infrastructure
