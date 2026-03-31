# aws-ec2-patch-management-automation

chmod +x scripts/patch_by_wave.sh

AWS_REGION=sa-east-1 ./scripts/patch_by_wave.sh


# AWS EC2 Patch Management Automation

Automated patch management for Amazon EC2 instances using AWS Systems Manager, Terraform, and a controlled multi-AZ rollout strategy.

---

## Overview

This project demonstrates how to automate patch management in a distributed EC2 environment using AWS native services.

Instead of applying patches to all instances at once, this solution implements a **wave-based rollout strategy**, reducing operational risk and preserving service availability.

The infrastructure is fully provisioned using Terraform and integrates with AWS Systems Manager (SSM) for patch orchestration.

---

## Problem

In real-world environments:

- Patching all servers at once can cause downtime
- Manual patching is error-prone and not scalable
- Lack of orchestration increases operational risk
- No clear rollout strategy leads to instability

---

## Solution

This project implements:

- EC2 instances distributed across multiple Availability Zones
- Tag-based targeting for flexible automation
- SSM Patch Baseline for controlled patch approval
- Maintenance Window for scheduled patching
- Custom script for **wave-based patch orchestration**

---

## Architecture

The environment simulates a distributed application across 3 Availability Zones:

- 3 EC2 instances (one per AZ)
- IAM role for SSM management
- Security Group with controlled access
- SSM Patch Baseline and Patch Group
- Maintenance Window for automated patch execution

> Diagram available in `/architecture/diagram.png`

---

## Technologies Used

- AWS EC2
- AWS Systems Manager (SSM)
- AWS IAM
- Terraform
- Bash scripting

---

## Patching Strategy

The patch process is executed in **waves**, based on instance tags:

| Wave | Description |
|------|------------|
| 1    | First AZ patched |
| 2    | Second AZ patched |
| 3    | Third AZ patched |

### Flow

1. Identify instances by tag (`PatchWave`)
2. Execute patch using SSM
3. Wait for completion
4. Validate instance state and SSM status
5. Proceed to next wave

### Why this matters

This approach:

- Reduces blast radius
- Preserves partial service capacity
- Mimics real-world production strategies
- Improves operational safety

---

## Project Structure
aws-ec2-patch-management-automation/
├── architecture/
├── docs/
├── terraform/
├── scripts/
└── README.md



---

## Deployment

### 1. Configure variables

Edit:
terraform/terraform.tfvars


Example:

```hcl
aws_region       = "sa-east-1"
ami_id           = "ami-xxxxxxxx"
subnet_id_az1    = "subnet-xxxx"
subnet_id_az2    = "subnet-xxxx"
subnet_id_az3    = "subnet-xxxx"
```

2. Initialize Terraform
</> Bash
cd terraform
terraform init

3. Plan
</> Bash
terraform plan

4. Apply
</> Bash
terraform apply

Validation
Before running patch automation
</> Bash
chmod +x scripts/validate_ssm_nodes.sh
AWS_REGION=sa-east-1 ./scripts/validate_ssm_nodes.sh

Expected:

Instances listed
SSM status = Online

Patch Execution (Wave-Based)
</> Bash
chmod +x scripts/patch_by_wave.sh
AWS_REGION=sa-east-1 ./scripts/patch_by_wave.sh

The script will:

Patch instances wave by wave
Wait for completion
Stop if any failure occurs
Outputs

After deployment, Terraform outputs include:

EC2 instance IDs
Public and private IPs
SSM Patch Baseline ID
Maintenance Window ID
Limitations

This project is a simplified demonstration:

No load balancer integration
No application-level health checks
No Auto Scaling Group
No rollback automation
Public IPs used for simplicity
Future Improvements
Integration with Application Load Balancer (ALB)
Auto Scaling Group rolling patch strategy
CloudWatch logging and monitoring
SNS notifications
Health checks (HTTP/systemd)
GitHub Actions for CI/CD
AMI-based patch pipeline
Key Takeaways

This project demonstrates:

Infrastructure as Code (Terraform)
AWS Systems Manager usage in real scenarios
Safe patch orchestration strategies
Tag-based automation design
Operational thinking applied to cloud environments

Author

Designed and implemented as part of a cloud infrastructure portfolio focused on automation, reliability, and real-world operational practices.
