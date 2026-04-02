# FunMechanicsTerraform

Terraform project for the Fun Mechanics website infrastructure on AWS.

It provisions:

- one VPC with IPv4 and AWS-assigned IPv6 space
- one public subnet with IPv4 and IPv6 addressing enabled
- an internet gateway and public route table for dual-stack internet access
- one Amazon Linux 2023 EC2 instance
  - Elastic IP-backed public IPv4
  - public IPv6
  - encrypted `gp3` root volume sized by `root_volume_size`
- an instance profile with:
  - `AmazonSSMManagedInstanceCore`
  - Route53 permissions for ACME DNS challenge
- a security group exposing MTG on `443` and the website on `8443` for IPv4 and IPv6
- a managed Elastic IP for stable public IPv4
- a Route53 `A` record for the configured `domain_name`
- EC2 user data that installs Caddy with the Route53 plugin, clones the site from GitHub, generates `/etc/caddy/Caddyfile`, and installs and configures [`mtg`](https://github.com/9seconds/mtg)

## Files

- `versions.tf`: Terraform and provider requirements
- `variables.tf`: inputs for network, instance, and domain settings
- `main.tf`: VPC, subnet, routing, EC2 instance, Route53 records, and bootstrap
- `iam.tf`: instance role, profile, and Route53 policy
- `outputs.tf`: public outputs
- `user_data.sh.tftpl`: bootstrap template for Amazon Linux
- `terraform.tfvars.example`: example input values
- `backend.hcl.example`: example S3 backend configuration for Terraform state

## Prerequisites

Before using this project, install the following tools on the machine that will run Terraform:

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

Verify both commands are available:

```bash
terraform version
aws --version
```

## AWS Setup

Prepare an AWS account and credentials before running Terraform:

1. Create or use an AWS account that owns the target infrastructure and domain DNS records.
2. Create an IAM user for Terraform automation with AdministratorAccess, or an equivalent permission set that covers EC2, IAM, VPC, Route53, and S3 state access.
3. Create an access key pair for that IAM user and store the access key ID and secret access key securely.
4. Configure the AWS CLI with those credentials:

```bash
aws configure
```

Provide:

- AWS Access Key ID
- AWS Secret Access Key
- default region, for example `eu-north-1`
- default output format, for example `json`

Confirm the CLI is authenticated:

```bash
aws sts get-caller-identity
```

## Route53 Setup

The domain used by `domain_name` should be managed by a public Route53 hosted zone:

1. Register the domain with your registrar, or use an existing registered domain.
2. Create a public hosted zone in Route53 for that domain.
3. Update the registrar nameservers so the domain delegates DNS to the Route53 hosted zone.
4. Put the hosted zone ID into `route53_zone_id` and the domain into `domain_name`.

Terraform creates DNS records in that hosted zone, so the zone must already exist before `terraform apply`.

## Usage

Copy the example variables file and adjust values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Copy the backend config example and fill in your state bucket details:

```bash
cp backend.hcl.example backend.hcl
```

Then initialize and apply:

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

To start an SSM session to the created instance, use the instance ID from the EC2 console or `terraform output` and run:

```bash
aws ssm start-session --target i-0123456789abcdef0
```

## Remote State

This project is configured to use the S3 backend for Terraform state.

Example backend config:

```hcl
bucket         = "funmechanics-terraform-state-180940737694"
key            = "prod/funmechanics.tfstate"
region         = "eu-north-1"
use_lockfile   = true
encrypt        = true
```

Recommended bucket settings:

- enable bucket versioning
- enable default SSE-S3 or SSE-KMS encryption
- block all public access
- keep the bucket dedicated to Terraform state

Create the bucket before running `terraform init`.

## Notes

- The bootstrap can clone a public website repository such as `https://github.com/example/example.git`.
- The active Caddy config is generated directly in userdata at `/etc/caddy/Caddyfile`, so the website repository does not need to ship a `Caddyfile`.
- The website content is cloned into `/srv/<site_name>`, controlled by the Terraform variable `site_name`.
- If the site repository becomes private, switch the bootstrap to SSH or another authenticated fetch method.
- Route53 access should be limited to the hosted zone ID for your own domain, for example `Z0123456789EXAMPLE`.
- The default AWS region is `eu-north-1`.
- The root EBS volume defaults to `20` GiB and is explicitly configured as encrypted `gp3` through `root_volume_size`.
- Terraform must run in a region and availability zone where Amazon Linux 2023 and IPv6-enabled VPC networking are available.
- `backend.hcl` should stay uncommitted if you put environment-specific state paths or bucket names in it.
- Bootstrap now installs `mtg` via `go install github.com/9seconds/mtg/v2@latest`, generates a secret with `mtg generate-secret --hex domain_name`, writes `/etc/mtg.toml`, and creates `mtg.service`.
- The generated `mtg` config follows the upstream example structure.
- It sets `public-ipv4`  from EC2 metadata to avoid external IP-discovery requests.
- It sets `[domain-fronting].port = 8443` and `[domain-fronting].ip = 127.0.0.1` so the fronting domain matches the website served by this stack.
- It enables the upstream-style `[defense.blocklist]` with `firehol_level1.netset`.
- It exposes local Prometheus metrics on `127.0.0.1:3129`.
