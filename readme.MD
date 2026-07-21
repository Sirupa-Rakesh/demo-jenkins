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
Terraform Workflow
Write Terraform Code
          │
          ▼
terraform fmt
          │
          ▼
terraform validate
          │
          ▼
terraform init
          │
          ▼
terraform plan
          │
          ▼
terraform apply
          │
          ▼
AWS Infrastructure Created
User Data Execution
EC2 Launch
     │
     ▼
Cloud-Init Starts
     │
     ▼
Reads user_data
     │
     ▼
Executes Shell Script
     │
     ▼
Installs Packages
     │
     ▼
Starts Services
     │
     ▼
Server Ready
DNS Flow
Browser
   │
   ▼
sonar.rakeshdev.online
   │
   ▼
Route53 Hosted Zone
   │
   ▼
A Record
   │
   ▼
Elastic IP
   │
   ▼
EC2 Instance
   │
   ▼
Docker
   │
   ▼
SonarQube
Jenkins Build Flow
Developer
     │
     ▼
Push Code to GitHub
     │
     ▼
GitHub Webhook
     │
     ▼
Jenkins Controller
     │
     ▼
Assign Job
     │
     ▼
Jenkins Agent
     │
     ▼
Build Project
     │
     ▼
Run Tests
     │
     ▼
SonarQube Scan
     │
     ▼
Docker Build
     │
     ▼
Deploy
Resource Explanation
Resource	Definition	Purpose
Provider	Connects Terraform to AWS	Allows Terraform to call AWS APIs
Variable	Input value	Makes code reusable
Local	Local reusable values	Avoids repeating code
Resource	Creates AWS infrastructure	EC2, SG, Route53, EIP
Data Source	Reads existing AWS resources	Default VPC, Subnet, Hosted Zone
Output	Displays values after Apply	Public IP, URLs
User Data	Script executed on first boot	Automatic software installation
Count	Creates resources conditionally	Enable/disable resources
Elastic IP	Static Public IP	Prevents IP changes
Route53	AWS DNS Service	Maps domain to server
Security Group	Virtual firewall	Controls inbound/outbound traffic
EC2	Virtual Machine	Runs Jenkins, SonarQube
Docker	Container platform	Runs SonarQube and PostgreSQL
Jenkins	CI/CD automation server	Builds and deploys applications
Jenkins Agent	Worker node	Executes build jobs
GitHub Runner	GitHub Actions executor	Runs GitHub workflow jobs
SonarQube	Code quality platform	Static analysis and quality checks
PostgreSQL	Relational database	Stores SonarQube data
AMI	Amazon Machine Image	Template used to launch EC2
Route53 A Record	Maps domain to IP	Resolves DNS queries
Root Block Device	EC2 storage volume	Stores operating system and data
Tags	Metadata for AWS resources	Helps identify and organize resources
How Each EC2 Works
Jenkins Controller
Hosts Jenkins UI
Manages jobs
Schedules builds
Connects with GitHub
Sends jobs to Jenkins Agents
Jenkins Agent
Executes Jenkins builds
Contains Docker
Contains Java
Contains kubectl
Contains Helm
Contains k9s
GitHub Runner
Executes GitHub Actions workflows
Builds applications
Runs Trivy scans
Executes Docker builds
Deploys applications
SonarQube Server
Runs inside Docker
Uses PostgreSQL database
Analyzes source code
Reports Bugs
Reports Vulnerabilities
Reports Code Smells
Generates Quality Gate results
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

This expanded README will look much more like a production-grade GitHub project. It explains not only what each component is, but also why it's used and how the entire infrastructure works end-to-end, making it valuable for recruiters, interviewers, and anyone reviewing your repository.


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
