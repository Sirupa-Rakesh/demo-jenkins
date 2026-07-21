# Jenkins + SonarQube CI/CD Infrastructure on AWS using Terraform

## Project Overview

This project provisions a full CI/CD infrastructure on AWS using **Terraform Infrastructure as Code (IaC)**.

It has grown beyond a single Jenkins box into a small CI/CD platform:

- **Jenkins server** — the main controller, reachable at a custom domain
- **Jenkins agent** — a build worker with Docker, Kubernetes tooling, and Helm pre-installed
- **SonarQube** — static code analysis server, backed by PostgreSQL, on its own subdomain
- **GitHub Actions runner** — a self-hosted runner for GitHub workflows (disabled by default)
- **Elastic IPs** — one per public-facing service, so the IP survives stop/start
- **Route 53 DNS records** — `jenkins.rakeshdev.online` and `sonar.rakeshdev.online`
- **One shared Security Group** — opens SSH, HTTP, Jenkins (8080), and SonarQube (9000)

Once Terraform finishes, Jenkins and SonarQube are each available on their own subdomain.

```
http://jenkins.rakeshdev.online:8080
http://sonar.rakeshdev.online:9000
```

-------------------------------------------------------------------------------------------------------------------------------------

## Architecture

```
                                Internet
                                    │
                                    ▼
                        Route53 hosted zone
                          (rakeshdev.online)
                          │                │
              jenkins.rakeshdev.online   sonar.rakeshdev.online
                          │                │
                          ▼                ▼
                  Elastic IP (Rakesh)  Elastic IP (sonarqube)
                          │                │
                          ▼                ▼
              ┌─────────────────┐  ┌─────────────────┐
              │  Jenkins server │  │   SonarQube      │
              │  (t3.micro)     │  │   (t3.large)     │
              │  port 8080      │  │   port 9000      │
              └────────┬────────┘  │  Postgres in      │
                       │           │  Docker network    │
                       ▼           └─────────────────┘
              ┌─────────────────┐  ┌─────────────────┐
              │  Jenkins agent  │  │  GitHub runner   │
              │  (t3.micro,     │  │  (t3.micro,      │
              │  Docker/K8s     │  │  disabled by     │
              │  tooling)       │  │  default)        │
              └─────────────────┘  └─────────────────┘

        All four instances share one Security Group (Sai-sg):
              22 (SSH) · 80 (HTTP) · 8080 (Jenkins) · 9000 (SonarQube)
```

*(See the diagram above for a live rendering of this layout.)*



-------------------------------------------------------------------------------------------------------------------------------------



Updated Architecture








                                                  Internet
                                                       │
                                                       │
                                   ┌───────────────┴────────────────┐
                                   │                                │
                                   ▼                                ▼
                              sai.rakeshdev.online             sonar.rakeshdev.online
                              Route53 DNS                     Route53 DNS
                                   │                                │
                                   ▼                                ▼
                              Elastic IP                      Elastic IP
                                   │                                │
                    ┌───────────────┘                                └───────────────┐
                    ▼                                                               ▼
               ┌──────────────────────┐                                  ┌──────────────────────┐
               │ Jenkins Controller   │                                  │ SonarQube Server     │
               │ Amazon EC2           │                                  │ Docker + PostgreSQL  │
               │ Java 21              │                                  │ Port 9000            │
               │ Jenkins              │                                  └──────────────────────┘
               └──────────┬───────────┘
                    │
                    │ SSH
                    ▼
               ┌──────────────────────┐
               │ Jenkins Agent        │
               │ Docker               │
               │ Java                 │
               │ kubectl              │
               │ Helm                 │
               │ K9s                  │
               └──────────┬───────────┘
                    │
                    ▼
               ┌──────────────────────┐
               │ GitHub Runner        │
               │ Docker               │
               │ Maven                │
               │ Python               │
               │ Trivy                │
               │ kubectl              │
               └──────────────────────┘

----------------------------------------------------------------------------------------------------------------------------------


Complete Infrastructure Flow



                                             terraform init
                                                  │
                                                  ▼
                                             Downloads AWS Provider
                                                  │
                                                  ▼
                                             terraform plan
                                                  │
                                                  ▼
                                        Calculates Execution Plan
                                                  │
                                                  ▼
                                             terraform apply
                                                  │
                                   ┌───────────────┼────────────────┐
                                   ▼               ▼                ▼
                              Read Default VPC  Read Subnet   Read Hosted Zone
                                   │               │                │
                                   └───────────────┼────────────────┘
                                                  ▼
                                        Create Security Group
                                                  │
                                   ┌─────────────┼─────────────┐
                                   ▼             ▼             ▼
                              Jenkins EC2    Agent EC2     SonarQube EC2
                                   │             │             │
                                   ▼             ▼             ▼
                              UserData      UserData      UserData
                                   │             │             │
                                   ▼             ▼             ▼
                              Install Jenkins   Install Tools  Install Docker
                                   │             │             │
                                   ▼             ▼             ▼
                              Elastic IP                    Elastic IP
                                   │                             │
                                   ▼                             ▼
                                   Route53 DNS                 Route53 DNS
                                   │                             │
                                   ▼                             ▼
                              Browser → Jenkins             Browser → SonarQube

-------------------------------------------------------------------------------------------------------------------------------------

Overall CI/CD Flow


Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins Trigger
    │
    ▼
Jenkins Controller
    │
    ▼
Jenkins Agent
    │
    ▼
Build
    │
    ▼
Test
    │
    ▼
SonarQube Analysis
    │
    ▼
Docker Image
    │
    ▼
Deploy

-------------------------------------------------------------------------------------------------------------------------------------

## Technologies Used

- Terraform (AWS provider `6.33.0`)
- AWS EC2, EIP, Security Groups, Route53, default VPC/Subnets (data sources)
- RHEL 9 "DevOps Practice" custom AMI (Jenkins/agent/runner)
- Ubuntu 24.04 SonarQube community AMI
- Jenkins, SonarQube (Docker), PostgreSQL (Docker)
- Java 21 (Amazon Corretto), Maven, Node.js 20, Python 3
- Docker, kubectl, kubens, k9s, Helm 3, Trivy
- GitHub Actions self-hosted runner (systemd service)

-------------------------------------------------------------------------------------------------------------------------------------

## Project Structure

```
terraform-jenkins/
│
├── provider.tf                # AWS provider + required_providers
├── variables.tf                # Input variables and feature toggles
├── data.tf                     # Custom AMI lookups (RHEL / SonarQube)
├── locals.tf                   # Derived values (ami_id, tags, subnet)
├── main.tf                     # EC2 instances, EIPs, Security Group, VPC/subnet/zone data
├── outputs.tf                  # Public IP and Jenkins URL outputs
├── route53.tf                  # DNS A records for Jenkins and SonarQube
├── 9-install.sh                # Jenkins server bootstrap script
├── 10-jenkins-agent.sh         # Jenkins agent bootstrap script
├── 11-runner.sh                # GitHub Actions runner bootstrap script
├── github-runner.service       # systemd unit for the runner
├── 13-sonarqube.sh             # SonarQube + Postgres bootstrap script
└── README.md
```

-------------------------------------------------------------------------------------------------------------------------------------

## Terraform Files Explained

### provider.tf

Pins the AWS provider version and configures the region.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.33.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

**required_providers** — tells Terraform exactly which provider plugin and version to download, so `terraform init` is reproducible across machines instead of silently picking up a newer, possibly breaking, provider release.

-------------------------------------------------------------------------------------------------------------------------------------

### variables.tf

Defines reusable inputs, including **feature toggle** booleans that turn whole resources on or off without editing the resource blocks themselves.

| Variable | Purpose |
|---|---|
| `region` | AWS region (`us-east-1`) |
| `ami_id` | Default AMI fallback |
| `instance_type` | Default instance size (`t3.micro`) |
| `domain_name` | Root domain (`rakeshdev.online`) |
| `subdomain` | Jenkins subdomain (`sai`) |
| `project` / `environment` | Used to build the `common_tags` map |
| `Rakesh` | Toggle: create the Jenkins server + its EIP |
| `sonar` | Toggle: create the SonarQube server + its EIP + DNS record |
| `jenkins` | Toggle: create the Jenkins agent |
| `runner` | Toggle: create the GitHub Actions runner (`false` by default) |

**Feature toggle pattern** — each conditional resource uses `count = var.X ? 1 : 0`. When the variable is `true`, Terraform creates exactly one of that resource; when `false`, it creates zero. This lets you spin individual services up or down (e.g. disable the runner to save cost) just by flipping a variable, instead of commenting out code.

-------------------------------------------------------------------------------------------------------------------------------------

### data.tf

Two **data sources** that look up existing AMIs by name instead of hardcoding an AMI ID (which changes per region and goes stale over time):

- `data.aws_ami.joindevops` — a custom RHEL 9 "DevOps Practice" image, used for Jenkins, the Jenkins agent, and the runner.
- `data.aws_ami.sonarqube` — a prebuilt Ubuntu 24.04 image with SonarQube dependencies baked in, used for the SonarQube server.

**Data source** — a Terraform block that *reads* information about something that already exists (an AMI, a VPC, a hosted zone) rather than creating it. Terraform doesn't manage the lifecycle of a data source's target; it just fetches details to use elsewhere in the config.

-------------------------------------------------------------------------------------------------------------------------------------

### locals.tf

Computes derived values once so they can be reused across resources:

```hcl
locals {
  ami_id            = var.ami_id
  common_tags        = { Project = var.project, Environment = var.environment, Terraform = "true" }
  public_subnet_id   = data.aws_subnets.default.ids[0]
}
```

**Locals** — named expressions, not user inputs. Unlike a `variable`, a `local` can't be overridden from the command line or a `.tfvars` file; it's Terraform's version of a computed constant, used here so every EC2 resource tags itself consistently via `common_tags` and picks the same subnet.

-------------------------------------------------------------------------------------------------------------------------------------

### main.tf

The core of the project. Creates, in order:

1. **`aws_instance.Rakesh`** — the Jenkins server, with a 50 GB `gp3` root volume, wired to the shared security group and the default subnet, bootstrapped by `9-install.sh`.
2. **`aws_eip.Rakesh`** — an Elastic IP bound to the Jenkins instance.
3. **`aws_instance.jenkins_agent`** — a `t3.micro` build agent bootstrapped by `10-jenkins-agent.sh`.
4. **`aws_instance.runner`** — a `t3.micro` GitHub Actions runner bootstrapped by `11-runner.sh` (only created when `var.runner = true`).
5. **`aws_instance.sonarqube`** — a `t3.large` SonarQube host (needs more CPU/RAM than the others) with a 150 GB root volume, bootstrapped by `13-sonarqube.sh`.
6. **`aws_eip.sonarqube`** — an Elastic IP bound to the SonarQube instance.
7. **`aws_security_group.Sai-sg`** — one shared security group for every instance above.
8. **Data sources** — `aws_vpc.default`, `aws_subnets.default`, `aws_route53_zone.domain` — read the existing default VPC, its subnets, and the pre-existing hosted zone rather than creating new ones.

**root_block_device** — the block that configures the EC2 instance's boot (root) EBS volume: its size in GB, its type (`gp3` is the current general-purpose SSD generation — cheaper and faster than the older `gp2`), and its own tags. Sizing this explicitly matters because SonarQube and its Postgres/Docker data need much more disk than a bare Jenkins install.

**`count = var.X ? 1 : 0`** — see *feature toggle pattern* above. Because these resources use `count`, referencing them elsewhere requires an index, e.g. `aws_instance.Rakesh[0].id` or `aws_eip.Rakesh[count.index]`.

-------------------------------------------------------------------------------------------------------------------------------------

### security-group.tf (now inside main.tf as `Sai-sg`)

One security group shared by all four instances.

| Port | Protocol | Purpose |
|---|---|---|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 8080 | TCP | Jenkins web UI |
| 9000 | TCP | SonarQube web UI |

Outbound: all traffic allowed.

**Security Group** — a virtual, stateful firewall attached to instances (not subnets). "Stateful" means a response to an allowed inbound request is automatically allowed back out, without needing a matching outbound rule.

-------------------------------------------------------------------------------------------------------------------------------------

### route53.tf

Creates two **A records**:

- `jenkins.rakeshdev.online` → the Jenkins Elastic IP
- `sonar.rakeshdev.online` → the SonarQube Elastic IP (only when `var.sonar = true`)

**A record** — a DNS record mapping a hostname directly to an IPv4 address. `ttl = 300` tells resolvers to cache that mapping for 5 minutes before re-checking it.

-------------------------------------------------------------------------------------------------------------------------------------

### outputs.tf

```hcl
output "public_ip" {
  value = aws_eip.Rakesh[0].public_ip
}

output "jenkins_url" {
  value = "http://${var.subdomain}.${var.domain_name}:8080"
}
```

Prints the Jenkins Elastic IP and full URL after `terraform apply` finishes.

-------------------------------------------------------------------------------------------------------------------------------------

## Bootstrap Scripts (`user_data`)

Each EC2 instance runs a shell script once, on first boot, via the `user_data` argument. This is how Terraform hands off from "instance exists" to "instance is actually configured."

### 9-install.sh — Jenkins server
- Clones the pipeline demo repo
- Installs Java 21 and Jenkins from the official Jenkins yum repo
- Enables and starts the `jenkins` service

### 10-jenkins-agent.sh — Jenkins agent
- Grows the root filesystem (the custom AMI's default volume is small, so this expands `/`, `/var`, `/home` with `growpart` + `lvextend` + `xfs_growfs`)
- Installs Java, Node.js 20, Docker
- Installs **kubectl**, **kubens**, **k9s**, and **Helm 3** — the standard Kubernetes operator toolkit — so builds on this agent can deploy to a cluster

### 11-runner.sh — GitHub Actions runner
- Same filesystem-growing step
- Installs Maven, Node.js, Python 3, Docker, the Kubernetes tooling above, plus **Trivy** (a container/IaC vulnerability scanner)
- `github-runner.service` is a systemd unit that keeps the GitHub Actions runner process (`run.sh`) alive and auto-restarting

### 13-sonarqube.sh — SonarQube server
- Installs Docker
- Creates a dedicated Docker network (`sonarqube`) so containers can resolve each other by name
- Runs **PostgreSQL** in a container as SonarQube's backing database
- Grows `/var` (Docker's data lives there) and prunes unused Docker data
- Runs **SonarQube** in a container, pointed at the Postgres container via `SONAR_JDBC_URL`

**Docker network** — a virtual bridge that lets containers on the same host talk to each other by container name (`postgres`, `sonarqube`) instead of hardcoded IPs.

-------------------------------------------------------------------------------------------------------------------------------------

## New Terms Glossary

| Term | Definition |
|---|---|
| **SonarQube** | A self-hosted static code analysis platform that scans source code for bugs, security vulnerabilities, and code smells, and reports a quality score for each project. |
| **Jenkins agent** | A separate machine (or container) that Jenkins' controller delegates build/test work to, so the controller itself stays lightweight and builds can run in parallel across multiple agents. |
| **GitHub Actions runner (self-hosted)** | A machine you provide and register with a GitHub repo/org so GitHub Actions workflows execute on your own infrastructure instead of GitHub's shared cloud runners — useful for custom tooling, private network access, or cost control. |
| **Trivy** | An open-source scanner that checks container images, filesystems, and IaC files (like Terraform) for known vulnerabilities and misconfigurations. |
| **k9s** | A terminal-based UI for navigating and managing a Kubernetes cluster interactively, instead of typing `kubectl` commands one at a time. |
| **kubens** | A small CLI utility for switching the active Kubernetes namespace quickly. |
| **Helm** | The package manager for Kubernetes — bundles a set of Kubernetes manifests into a reusable, versioned "chart" that can be installed/upgraded with one command. |
| **gp3 volume** | The current generation of AWS general-purpose SSD (EBS) storage — cheaper per GB and with independently configurable IOPS/throughput compared to the older `gp2` type. |
| **Elastic IP (EIP)** | A static public IPv4 address you allocate in your AWS account and attach to an instance. Unlike an instance's default public IP, it doesn't change if the instance stops and starts. |
| **Security Group** | A stateful virtual firewall attached directly to EC2 instances/ENIs, controlling inbound and outbound traffic by port and protocol. |
| **Data source (Terraform)** | A Terraform block that reads/looks up an existing resource (AMI, VPC, hosted zone) rather than creating a new one. |
| **Locals (Terraform)** | Named, computed expressions internal to a Terraform config — not settable from outside, unlike variables. |
| **`count` meta-argument** | Turns a resource block into a conditional or repeated resource; `count = var.x ? 1 : 0` creates the resource only if the boolean variable is true. |
| **`required_providers`** | A block that pins the exact provider (e.g. `hashicorp/aws`) and version Terraform must use, keeping `terraform init` reproducible. |
| **Docker network** | A virtual network Docker creates so containers can reach each other by container name, isolated from the host's default networking. |
| **root_block_device** | The Terraform block configuring an EC2 instance's boot volume — size, type, and tags. |
| **A record** | A DNS record type mapping a hostname to an IPv4 address. |
| **TTL (Time To Live)** | How long (in seconds) a DNS resolver is allowed to cache a record before re-querying it. |

-------------------------------------------------------------------------------------------------------------------------------------

## Prerequisites

- AWS Account with an IAM user (Administrator Access or scoped EC2/VPC/Route53/EIP permissions)
- AWS CLI installed and configured (`aws configure`, verify with `aws sts get-caller-identity`)
- Terraform installed
- An existing Route53 hosted zone for your domain
- A registered domain name

-------------------------------------------------------------------------------------------------------------------------------------

## Deploying

```bash
terraform init      # downloads the AWS provider (6.33.0)
terraform fmt        # formats the files
terraform validate   # checks syntax
terraform plan        # shows what will be created
terraform apply       # creates it — type "yes" to confirm
```

Toggle which services get built by editing `variables.tf` before applying:

```hcl
variable "Rakesh"  { default = true  }  # Jenkins server
variable "sonar"   { default = true  }  # SonarQube
variable "jenkins" { default = true  }  # Jenkins agent
variable "runner"  { default = false } # GitHub Actions runner
```

## Verifying

```bash
# Jenkins
ssh -i mykey.pem ec2-user@<jenkins-eip>
systemctl status jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# -> http://jenkins.rakeshdev.online:8080

# SonarQube
ssh -i mykey.pem ec2-user@<sonarqube-eip>
docker ps
# -> http://sonar.rakeshdev.online:9000  (default login: admin/admin)
```

## Tearing Down

```bash
terraform destroy   # type "yes" to confirm
```

Removes every instance, EIP, the security group, and both DNS records.

---

## Future Improvements

- HTTPS via AWS Certificate Manager + Application Load Balancer
- Auto Scaling Group for Jenkins agents
- Remote Terraform state in S3 with DynamoDB locking
- IAM instance roles instead of static credentials
- CloudWatch monitoring and alerting
- Jenkins/SonarQube backups to S3
- Multi-environment (dev/test/prod) workspaces

-------------------------------------------------------------------------------------------------------------------------------------

## Author

**Rakesh Sirupa**


--DevOps Engineer

Skills:-
  AWS 
· Terraform 
· Jenkins 
· SonarQube 
· Docker 
· Kubernetes 
· Git & GitHub 
· Linux 
· CI/CD 
· Route53 
· Infrastructure as Code