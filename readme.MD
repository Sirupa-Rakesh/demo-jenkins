# Jenkins Infrastructure on AWS using Terraform

## Project Overview

This project provisions a complete Jenkins server on AWS using **Terraform Infrastructure as Code (IaC)**.

The infrastructure includes:

- AWS EC2 Instance
- Security Group
- Elastic IP (Static Public IP)
- Route 53 DNS Record
- Automatic Java Installation
- Automatic Jenkins Installation
- Outputs for Public IP and Jenkins URL

Once Terraform finishes, Jenkins will be available through your custom domain.

Example:

```
http://jenkins.example.com:8080
```

---

# Architecture

```
                      Internet
                          │
                          ▼
                jenkins.example.com
                    (Route53 DNS)
                          │
                          ▼
                    Elastic IP (EIP)
                          │
                          ▼
                 EC2 Instance (Amazon Linux)
                          │
          ┌───────────────┴───────────────┐
          │                               │
        Java                          Jenkins
          │                               │
          └───────────────┬───────────────┘
                          │
              http://jenkins.example.com:8080
```

---

# Technologies Used

- Terraform
- AWS EC2
- AWS Route53
- AWS Security Groups
- AWS Elastic IP
- Amazon Linux 2023
- Jenkins
- Java 21 (Amazon Corretto)

---

# Project Structure

```
terraform-jenkins/
│
├── provider.tf
├── variables.tf
├── main.tf
├── security-group.tf
├── ec2.tf
├── eip.tf
├── route53.tf
├── outputs.tf
├── terraform.tfvars
├── install.sh
└── README.md
```

---

# Terraform Files Explanation

## provider.tf

Configures the AWS Provider.

Terraform uses this provider to communicate with AWS APIs.

```hcl
provider "aws" {
  region = var.region
}
```

---

## variables.tf

Defines reusable input variables.

Variables make the code reusable without modifying the source code.

Variables used:

- region
- ami
- instance_type
- key_name
- domain_name
- subdomain

---

## terraform.tfvars

Contains actual values for the variables.

Example:

```hcl
region = "us-east-1"

ami = "ami-xxxxxxxx"

instance_type = "t2.micro"

key_name = "my-key"

domain_name = "example.com"

subdomain = "jenkins"
```

---

## main.tf

Reads existing AWS resources.

This project reads:

- Default VPC
- Default Subnet
- Existing Route53 Hosted Zone

Terraform does not create these resources.

---

## security-group.tf

Creates a Security Group.

Allowed Ports:

| Port | Protocol | Purpose |
|-------|----------|----------|
|22|TCP|SSH|
|80|TCP|HTTP|
|8080|TCP|Jenkins|

Outbound:

All traffic allowed.

---

## ec2.tf

Creates the Jenkins EC2 Instance.

Attached Resources:

- Security Group
- Key Pair
- Default Subnet

During instance launch,

Terraform executes:

```
install.sh
```

which automatically installs Jenkins.

---

## install.sh

Executed only once during EC2 boot.

Tasks:

- Update OS
- Install Java
- Add Jenkins Repository
- Install Jenkins
- Enable Jenkins
- Start Jenkins

No manual installation is required.

---

## eip.tf

Creates an Elastic IP.

Why?

Normal Public IP changes after stopping and starting an EC2 instance.

Elastic IP remains the same.

This keeps the Route53 record working.

---

## route53.tf

Creates a DNS Record.

Example:

```
jenkins.example.com
```

points to

```
Elastic IP
```

Record Type:

```
A Record
```

---

## outputs.tf

Displays useful information after Terraform Apply.

Outputs:

- Public IP
- Jenkins URL

Example:

```
Outputs:

public_ip = 44.xx.xx.xx

jenkins_url = http://jenkins.example.com:8080
```

---

# Prerequisites

Before running Terraform, ensure the following are available:

- AWS Account
- IAM User with Administrator Access (or appropriate permissions)
- AWS CLI installed
- Terraform installed
- Existing Route53 Hosted Zone
- Registered Domain Name
- EC2 Key Pair

---

# Required AWS Permissions

Terraform needs permissions for:

- EC2
- VPC
- Security Groups
- Elastic IP
- Route53

---

# Configure AWS Credentials

```
aws configure
```

Provide:

```
AWS Access Key

AWS Secret Key

Region

Output Format
```

Verify:

```
aws sts get-caller-identity
```

---

# Initialize Terraform

```
terraform init
```

Downloads the AWS Provider.

---

# Validate Configuration

```
terraform validate
```

Checks Terraform syntax.

---

# Format Terraform Code

```
terraform fmt
```

Formats Terraform files.

---

# Review Execution Plan

```
terraform plan
```

Shows resources Terraform will create.

---

# Deploy Infrastructure

```
terraform apply
```

Type:

```
yes
```

Terraform will create:

- Security Group
- EC2 Instance
- Elastic IP
- Route53 Record

It will also install Jenkins automatically.

---

# Verify Jenkins

SSH into EC2:

```
ssh -i mykey.pem ec2-user@<Elastic-IP>
```

Check Jenkins status:

```
systemctl status jenkins
```

Get initial admin password:

```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open browser:

```
http://jenkins.example.com:8080
```

---

# Terraform Destroy

To remove all created resources:

```
terraform destroy
```

Type:

```
yes
```

Terraform deletes:

- EC2
- Security Group
- Elastic IP
- Route53 Record

---

# Infrastructure Flow

```
Terraform Apply
        │
        ▼
Reads Default VPC
        │
        ▼
Reads Default Subnet
        │
        ▼
Reads Route53 Hosted Zone
        │
        ▼
Creates Security Group
        │
        ▼
Creates EC2 Instance
        │
        ▼
Runs install.sh
        │
        ▼
Installs Java
        │
        ▼
Installs Jenkins
        │
        ▼
Creates Elastic IP
        │
        ▼
Associates Elastic IP
        │
        ▼
Creates Route53 Record
        │
        ▼
Access Jenkins using
jenkins.example.com
```

---

# Key Terraform Concepts Used

- Provider
- Variables
- Resources
- Data Sources
- Outputs
- User Data
- Security Groups
- Route53 Records
- Elastic IP
- EC2 Instance

---

# Learning Outcomes

After completing this project, you will understand how to:

- Provision AWS infrastructure using Terraform.
- Create an EC2 instance automatically.
- Configure Security Groups.
- Install Jenkins using EC2 User Data.
- Allocate and attach an Elastic IP.
- Create Route53 DNS records.
- Access Jenkins using a custom domain.
- Manage infrastructure with Terraform lifecycle commands (`init`, `plan`, `apply`, and `destroy`).

---

# Future Improvements

- HTTPS using AWS Certificate Manager (ACM)
- Application Load Balancer (ALB)
- Auto Scaling Group
- Remote Terraform State with S3
- DynamoDB State Locking
- IAM Role for EC2
- CloudWatch Monitoring
- Jenkins Backup using Amazon S3
- SSL Termination
- Multi-Environment Deployment (Dev, Test, Prod)

---

# Author

**Rakesh Sirupa**

DevOps Engineer

Skills:

- AWS
- Terraform
- Jenkins
- Docker
- Kubernetes
- Git & GitHub
- Linux
- CI/CD
- Route53
- Infrastructure as Code