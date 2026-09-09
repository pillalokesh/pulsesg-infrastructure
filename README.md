# PulseSG Infrastructure

Reusable Terraform for a shared AWS platform in `ap-south-1`: VPC, EKS, managed node groups, IAM, security groups, ECR, and EKS add-ons. One environment owns one shared cluster; applications share it through namespaces owned by their application repositories. This repository does not create application deployments, services, namespaces, or Helm releases.

## Structure

`terraform/modules/{vpc,eks,ecr,iam,security}` contains reusable resources. `terraform/environments/dev` composes them and owns environment-specific values. Copy that composition for `qa`, `uat`, and `prod`, using a separate backend key and account configuration.

## Backend bootstrap

Create the S3 state bucket separately because Terraform cannot initialize a backend that it must create itself. The backend uses S3 versioning/encryption and Terraform's native lock file (`use_lockfile = true`), which is the current locking approach; no DynamoDB table is required. Replace the bucket/key in `backend.tf` before `terraform init`, or pass them with `-backend-config`.

## Prerequisites and commands

Use Terraform >= 1.10, AWS CLI SSO/profile or an assumed role, and permissions for the selected account. Never commit access keys or secrets.

```powershell
cd terraform/environments/dev
terraform init
terraform fmt -recursive ..\..
terraform validate
terraform plan -out dev.tfplan
terraform apply dev.tfplan
terraform destroy
```

The default dev example permits API access from anywhere for initial usability; restrict `cluster_api_allowed_cidrs` to operator or VPN CIDRs before real use. One NAT gateway per AZ is resilient but costs more; reduce it only for disposable environments.

## Reuse and CI/CD

Add an application repository name to `ecr_repository_names`, apply, then let that application's Jenkins pipeline create its namespace and run Helm. The pipeline builds Maven code, builds and pushes an immutable-tagged image to its ECR repository, and deploys its Helm chart to the shared EKS cluster. Prefer Jenkins instance profiles, OIDC, IRSA, or role assumption over long-lived access keys. The optional Jenkins role is restricted to configured ECR repositories and EKS discovery, while the EKS access entry is explicit and can be changed to a narrower EKS access policy.

Outputs include VPC/subnet IDs, EKS identifiers and endpoint, ECR URLs, and IAM role ARNs.
