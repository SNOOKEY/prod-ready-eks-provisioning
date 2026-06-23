# Production-Ready EKS Provisioning with Terraform

A comprehensive Terraform-based infrastructure-as-code project for deploying a production-grade, highly available Amazon EKS (Elastic Kubernetes Service) cluster on AWS with complete networking, IAM, security, and secrets management.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Configuration Variables](#configuration-variables)
- [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
- [Outputs](#outputs)
- [Node Groups](#node-groups)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)
- [Cost Estimation](#cost-estimation)

## 🎯 Overview

This Terraform project automates the complete provisioning of a production-ready EKS cluster with:

- **Networking**: Custom VPC with public and private subnets across 3 availability zones
- **Compute**: EKS cluster with mixed node groups (on-demand and spot instances)
- **Security**: IAM roles, security groups, KMS encryption, and encrypted secrets management
- **Observability**: CloudWatch logging and monitoring capabilities
- **High Availability**: Multi-AZ deployment with auto-scaling capabilities
- **Secrets Management**: AWS Secrets Manager for database credentials, API keys, and app configuration

## ✨ Features

- ✅ **High Availability**: Multi-AZ deployment across 3 availability zones
- ✅ **Dual Node Groups**: On-demand for steady workloads, Spot for cost optimization
- ✅ **IRSA Support**: IAM Roles for Service Accounts for secure pod-level permissions
- ✅ **Private API Endpoints**: Secure cluster communication with private access
- ✅ **Encryption**: KMS encryption for cluster and secrets
- ✅ **Secrets Management**: AWS Secrets Manager integration for credentials
- ✅ **VPC Architecture**: NAT Gateway, Internet Gateway, and proper network segmentation
- ✅ **CloudWatch Integration**: Cluster logging and monitoring
- ✅ **Modular Design**: Well-organized modules for easy customization

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Region                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                         VPC (10.0.0.0/16)                  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │              Public Subnets (3 AZs)                 │  │  │
│  │  │  ┌─────────────────────────────────────────────┐    │  │  │
│  │  │  │   NAT Gateway + Internet Gateway            │    │  │  │
│  │  │  │   Load Balancer Ingress Points              │    │  │  │
│  │  │  └─────────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │             Private Subnets (3 AZs)                 │  │  │
│  │  │  ┌─────────────────────────────────────────────┐    │  │  │
│  │  │  │        EKS Cluster Control Plane            │    │  │  │
│  │  │  │   ┌──────────────┐  ┌────────────────┐     │    │  │  │
│  │  │  │   │ On-Demand    │  │  Spot Node     │     │    │  │  │
│  │  │  │   │ Node Group   │  │  Group         │     │    │  │  │
│  │  │  │   │ (2-4 nodes)  │  │  (1-3 nodes)   │     │    │  │  │
│  │  │  │   └──────────────┘  └────────────────┘     │    │  │  │
│  │  │  │   KMS Encryption + Security Groups         │    │  │  │
│  │  │  └─────────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    AWS Services                            │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐      │  │
│  │  │   Secrets    │ │  CloudWatch  │ │   IAM Roles  │      │  │
│  │  │   Manager    │ │     Logs     │ │   & Policies │      │  │
│  │  └──────────────┘ └──────────────┘ └──────────────┘      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Prerequisites

### Required Software

Before deploying this infrastructure, ensure you have the following tools installed:

| Tool | Minimum Version | Purpose | Install Link |
|------|-----------------|---------|--------------|
| Terraform | 1.0.0+ | Infrastructure as Code | [terraform.io/downloads](https://www.terraform.io/downloads) |
| AWS CLI | 2.0+ | AWS API interaction | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| kubectl | 1.24+ | Kubernetes cluster management | [kubernetes.io/docs/tasks/tools](https://kubernetes.io/docs/tasks/tools/) |
| aws-iam-authenticator | Latest | IAM authentication for EKS | [github.com/kubernetes-sigs/aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) |

### AWS Account Requirements

1. **Active AWS Account** with billing enabled
2. **AWS Credentials** configured locally
3. **IAM Permissions** to create:
   - VPC, Subnets, Route Tables, NAT Gateways, Internet Gateways, Security Groups
   - EKS Cluster and Node Groups
   - IAM Roles and Policies
   - KMS Keys
   - CloudWatch Log Groups
   - Secrets Manager Secrets
   - EC2 Instances

### Prerequisite Setup

```bash
# 1. Install Terraform (macOS with Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 2. Configure AWS Credentials
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your preferred region (e.g., eu-north-1)
# Enter output format (json recommended)

# 3. Verify AWS Configuration
aws sts get-caller-identity

# 4. Verify Terraform Installation
terraform version

# 5. Verify kubectl Installation
kubectl version --client
```

## 📂 Project Structure

```
prod-ready-eks-provisioning/
├── main.tf                      # Root configuration - orchestrates all modules
├── variables.tf                 # Input variable definitions
├── providers.tf                 # AWS provider configuration
├── README.md                    # This file
├── .gitignore                   # Git ignore patterns
├── terraform.tfvars.example     # Example variables file
│
└── modules/
    │
    ├── vpc/                     # VPC and Networking Module
    │   ├── main.tf              # VPC, subnets, IGW, NAT
    │   ├── variables.tf         # VPC-specific variables
    │   └── output.tf            # VPC outputs (IDs, subnets, etc.)
    │
    ├── eks/                     # EKS Cluster Module
    │   ├── main.tf              # EKS cluster, node groups, security
    │   ├── variables.tf         # EKS-specific variables
    │   ├── output.tf            # EKS outputs (cluster info, node groups)
    │   └── templates/           # User data templates
    │       └── userdata.sh      # Node initialization script
    │
    ├── iam/                     # IAM Roles and Policies Module
    │   ├── main.tf              # Cluster role, node role, IRSA
    │   ├── variables.tf         # IAM-specific variables
    │   └── output.tf            # IAM outputs (role ARNs, etc.)
    │
    └── secrets-manager/         # AWS Secrets Manager Module
        ├── main.tf              # Database, API, and app config secrets
        ├── variables.tf         # Secrets-specific variables
        └── output.tf            # Secrets outputs (secret names, ARNs)
```

## ⚙️ Configuration Variables

### VPC Configuration

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | string |
| `private_subnets` | CIDR blocks for private subnets (3 AZs) | See code | list(string) |
| `public_subnets` | CIDR blocks for public subnets (3 AZs) | See code | list(string) |

### EKS Configuration

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `cluster_name` | Name of the EKS cluster | `production-grade` | string |
| `kubernates_version` | Kubernetes version for cluster | `1.31` | string |
| `aws_region` | AWS region for resources | `eu-north-1` | string |
| `environment` | Environment name (dev/staging/prod) | `production` | string |

### Secrets Configuration

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `enable_db_secret` | Enable database secret creation | `true` | bool |
| `enable_api_secret` | Enable API secret creation | `true` | bool |
| `enable_app_config_secret` | Enable app config secret creation | `true` | bool |

## 🚀 Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/SNOOKEY/prod-ready-eks-provisioning.git
cd prod-ready-eks-provisioning
```

### Step 2: Configure AWS Credentials

```bash
# Configure your AWS credentials
aws configure

# Verify configuration
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "XXXXXXXXXXXXX:user",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

### Step 3: Create terraform.tfvars File

```bash
cat > terraform.tfvars << 'EOF'
# AWS Configuration
aws_region          = "eu-north-1"
environment         = "production"

# Cluster Configuration
cluster_name        = "production-grade"
kubernates_version  = "1.31"

# VPC Configuration
vpc_cidr            = "10.0.0.0/16"
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

# Secrets Management
enable_db_secret           = true
enable_api_secret          = true
enable_app_config_secret   = true
EOF
```

> ⚠️ **Important**: Add `terraform.tfvars` to `.gitignore` to prevent committing sensitive data:
> ```bash
> echo "terraform.tfvars" >> .gitignore
> ```

## 📋 Step-by-Step Deployment Guide

### Step 1: Validate Configuration

```bash
# Check Terraform syntax
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform working directory
terraform init

# This command will:
# - Create .terraform directory
# - Download provider plugins
# - Initialize backend
```

### Step 3: Plan the Deployment

```bash
# Generate execution plan
terraform plan -out=tfplan

# Review the output carefully:
# - Terraform will show all resources to be created
# - Verify the cluster name, region, and node counts
# - Check if any sensitive data is exposed (should not be)

# To see plan in human-readable format
terraform show tfplan
```

### Step 4: Apply the Configuration

```bash
# Apply the infrastructure changes
terraform apply tfplan

# Or apply without saved plan (requires 'yes' confirmation)
terraform apply

# Expected duration: 15-20 minutes

# Monitor progress in another terminal:
# aws eks describe-cluster --name production-grade --region eu-north-1
```

### Step 5: Retrieve Cluster Information

```bash
# Get cluster name
CLUSTER_NAME=$(terraform output -raw cluster_name)
echo $CLUSTER_NAME

# Get cluster endpoint
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
echo $CLUSTER_ENDPOINT

# Get cluster security group
SECURITY_GROUP=$(terraform output -raw cluster_security_group_id)
echo $SECURITY_GROUP
```

### Step 6: Configure kubectl

```bash
# Update kubeconfig for the cluster
aws eks update-kubeconfig \
  --region $(terraform output -raw aws_region) \
  --name $(terraform output -raw cluster_name)

# Verify kubeconfig
cat ~/.kube/config | grep -A5 "cluster_name"
```

### Step 7: Verify Cluster Access

```bash
# Test kubectl connection
kubectl cluster-info

# Expected output should show:
# Kubernetes control plane is running at https://xxxxx.eks.amazonaws.com
# CoreDNS is running at https://xxxxx.eks.amazonaws.com/api/v1/...

# Get cluster information
kubectl get cluster-info dump

# List API resources
kubectl api-resources
```

### Step 8: Verify Nodes

```bash
# List all nodes
kubectl get nodes

# Expected output:
# NAME                          STATUS   ROLES    AGE   VERSION
# ip-10-0-101-xxx.ec2.internal  Ready    <none>   2m    v1.31.x
# ip-10-0-102-xxx.ec2.internal  Ready    <none>   2m    v1.31.x

# Get detailed node information
kubectl get nodes -o wide

# Describe a specific node
kubectl describe node <node-name>
```

### Step 9: Verify Node Groups

```bash
# List node groups from AWS
aws eks list-nodegroups \
  --cluster-name $(terraform output -raw cluster_name) \
  --region $(terraform output -raw aws_region)

# Describe node group
aws eks describe-nodegroup \
  --cluster-name $(terraform output -raw cluster_name) \
  --nodegroup-name general \
  --region $(terraform output -raw aws_region)
```

### Step 10: Deploy a Test Application

```bash
# Create a simple deployment to verify cluster functionality
kubectl create deployment test-app --image=nginx:latest

# Verify deployment
kubectl get deployments
kubectl get pods

# Expose the deployment
kubectl expose deployment test-app --type=LoadBalancer --port=80 --target-port=80

# Get service details
kubectl get services

# Clean up test resources
kubectl delete deployment test-app
kubectl delete service test-app
```

## 📤 Outputs

After successful deployment, retrieve outputs using:

```bash
# Get all outputs
terraform output

# Get specific outputs
CLUSTER_NAME=$(terraform output -raw cluster_name)
VPC_ID=$(terraform output -raw vpc_id)
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
NODE_ROLE_ARN=$(terraform output -raw node_role_arn)

# Export as environment variables
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export AWS_REGION=$(terraform output -raw aws_region)
export VPC_ID=$(terraform output -raw vpc_id)
```

### Key Outputs Explained

| Output | Description | Usage |
|--------|-------------|-------|
| `cluster_name` | Name of the EKS cluster | kubectl configuration |
| `cluster_endpoint` | Kubernetes API endpoint | kubectl commands |
| `cluster_security_group_id` | Cluster security group | Security policies |
| `vpc_id` | VPC ID | Network management |
| `private_subnets` | Private subnet IDs | Application deployment |
| `public_subnets` | Public subnet IDs | Load balancer configuration |
| `node_role_arn` | IAM role for nodes | IRSA, permissions |
| `cluster_role_arn` | IAM role for cluster | Cluster permissions |

## 🎯 Node Groups

### General Node Group (On-Demand)

**Configuration:**
```
Instance Type:   t2.micro
Desired Size:    2
Min Size:        2
Max Size:        4
Capacity Type:   ON_DEMAND
Disk Size:       20 GB
```

**Use Cases:**
- System pods (CoreDNS, kube-proxy, VPC CNI)
- Critical applications requiring guaranteed availability
- Predictable, steady-state workloads

**Access:**
```bash
# List nodes in general group
kubectl get nodes -L node.kubernetes.io/instance-type

# Add node to this group
aws eks update-nodegroup-config \
  --cluster-name production-grade \
  --nodegroup-name general \
  --scaling-config desiredSize=3,minSize=2,maxSize=5
```

### Spot Node Group

**Configuration:**
```
Instance Types:  t2.micro, t3.micro
Desired Size:    1
Min Size:        1
Max Size:        3
Capacity Type:   SPOT
Disk Size:       20 GB
Taints:          spot=true:NoSchedule
```

**Use Cases:**
- Batch processing jobs
- Data analysis workloads
- Fault-tolerant applications
- Cost optimization

**Toleration for Spot Nodes:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-job
spec:
  template:
    spec:
      tolerations:
      - key: "spot"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      nodeSelector:
        workload-type: batch
```

## 🧹 Cleanup

### Remove All Infrastructure

```bash
# 1. Delete Kubernetes resources
kubectl delete all --all-namespaces

# 2. Delete any persistent volumes
kubectl delete pvc --all-namespaces

# 3. Destroy Terraform resources
terraform destroy

# 4. Confirm with 'yes' when prompted

# 5. Verify destruction
aws eks describe-cluster \
  --name production-grade \
  --region eu-north-1 \
  # Should return error "Cluster not found"
```

### Partial Cleanup (Keep Cluster, Remove Secrets)

```bash
# Remove only secrets
terraform destroy -target=module.secrets_manager

# Keep VPC and EKS cluster running
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue: "ResourceLimitExceeded: You have reached a quota"

**Solution:**
```bash
# Check current quotas
aws service-quotas list-service-quotas \
  --service-code ec2 \
  --query 'ServiceQuotas[?ServiceCode==`ec2`]'

# Request quota increase
aws service-quotas request-service-quota-increase \
  --service-code ec2 \
  --quota-code L-1216C47A \
  --desired-value 10
```

#### Issue: Nodes stuck in "NotReady" state

```bash
# Check node status
kubectl describe nodes

# View CloudWatch logs
aws logs tail /aws/eks/production-grade/cluster --follow

# SSH into node and check logs (if using SSH key)
ssh ec2-user@<node-ip>
journalctl -u kubelet
```

#### Issue: kubectl: command not found

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### Issue: Unable to connect to cluster

```bash
# Reconfigure kubeconfig
aws eks update-kubeconfig \
  --name production-grade \
  --region eu-north-1 \
  --force

# Test IAM authenticator
aws-iam-authenticator token -i production-grade
```

#### Issue: Terraform state is corrupted

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Refresh state
terraform refresh

# If needed, import existing resources
terraform import aws_eks_cluster.eks production-grade
```

## 🔒 Security Best Practices

### 1. **Network Security**

```hcl
# Use private subnets for workloads
- Private subnets: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
- Public subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
```

- Load balancers in public subnets
- Applications in private subnets
- NAT gateway for outbound traffic

### 2. **IRSA (IAM Roles for Service Accounts)**

```yaml
# Example: Give pod access to S3
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/app-role

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  template:
    spec:
      serviceAccountName: app-sa
```

### 3. **Secrets Management**

```bash
# Retrieve secrets from AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id production-grade-db-secret \
  --region eu-north-1

# Create Kubernetes secret from AWS secret
kubectl create secret generic db-credentials \
  --from-literal=username=$(aws secretsmanager get-secret-value \
    --secret-id production-grade-db-secret \
    --query 'SecretString' --output text | jq -r .username)
```

### 4. **Encryption**

- ✅ KMS encryption for cluster API data
- ✅ Encrypted EBS volumes
- ✅ Encrypted secrets in transit

### 5. **Logging & Monitoring**

```bash
# Enable CloudWatch logging
kubectl logs -n kube-system -l k8s-app=aws-node --tail=100

# Monitor cluster metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EKS \
  --metric-name ResourceUtilization \
  --dimensions Name=ClusterName,Value=production-grade \
  --start-time 2024-06-20T00:00:00Z \
  --end-time 2024-06-23T00:00:00Z \
  --period 3600 \
  --statistics Average
```

## 💰 Cost Estimation

### Monthly Costs (Approximate - eu-north-1)

| Component | Quantity | Unit Cost | Monthly Cost |
|-----------|----------|-----------|--------------|
| EKS Cluster | 1 | $73.00 | $73.00 |
| NAT Gateway | 3 | $10.90/month | $32.70 |
| EC2 (On-Demand, t2.micro) | 2 | $7.50 | $15.00 |
| EC2 (Spot, t2.micro) | 1 | ~$2.50 | ~$5.00 |
| Data Transfer (outbound) | 100 GB | $0.02/GB | $2.00 |
| Secrets Manager | 3 secrets | $0.40/secret | $1.20 |
| CloudWatch Logs | 10 GB | $0.50/GB | $5.00 |
| **Total** | | | **~$134.70** |

### Cost Optimization Tips

1. Use **Spot instances** for non-critical workloads
2. **Auto-scale** nodes based on demand
3. **Right-size** instances for your workload
4. **Consolidate** workloads on fewer nodes
5. Use **Reserved Instances** for predictable workloads
6. Monitor with **AWS Trusted Advisor**

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI EKS Commands](https://docs.aws.amazon.com/cli/latest/reference/eks/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 📧 Support & Questions

For issues, feature requests, or questions:
1. Check [existing GitHub issues](https://github.com/SNOOKEY/prod-ready-eks-provisioning/issues)
2. Create a [new GitHub issue](https://github.com/SNOOKEY/prod-ready-eks-provisioning/issues/new)
3. Include error messages, terraform version, and region information

---

**Last Updated**: June 23, 2026  
**Terraform Version**: >= 1.0.0  
**AWS Provider**: >= 5.0.0  
**Kubernetes Version**: 1.31+