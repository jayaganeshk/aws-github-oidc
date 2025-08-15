# AWS GitHub OIDC - Secure Multi-Environment Deployments

This repository demonstrates how to set up secure, multi-environment AWS deployments from GitHub Actions using OpenID Connect (OIDC) instead of long-lived AWS access keys. The setup eliminates the need for storing static AWS credentials in GitHub while enabling clean, environment-aware deployments across dev/test/prod environments.

## 🏗️ Architecture Overview

![Architecture Diagram](screenshots/github_oidc.png)

The solution uses GitHub's OIDC provider to assume AWS IAM roles with temporary credentials, providing:

- **Security**: No long-lived AWS keys stored in GitHub
- **Fine-grained access**: Environment-specific IAM roles with least privilege
- **Multi-environment support**: Deploy to multiple AWS accounts from a single repository
- **Manual approval workflow**: Review Terraform plans before deployment

## 🚀 Features

- **OIDC Authentication**: Secure authentication using GitHub's OIDC provider
- **Multi-Environment Support**: Separate configurations for dev, test, and prod
- **Terraform Integration**: Infrastructure as Code with S3 backend
- **Manual Approval Process**: Review and approve deployments via GitHub Issues
- **Environment Isolation**: Deploy to different AWS accounts per environment

## 📁 Repository Structure

```
├── .github/
│   └── workflows/
│       └── deploy-terraform.yml    # GitHub Actions workflow
├── terraform/
│   ├── env/
│   │   ├── dev.tfvars             # Development environment variables
│   │   ├── test.tfvars            # Test environment variables
│   │   └── prod.tfvars            # Production environment variables
│   ├── main.tf                    # Main Terraform configuration
│   ├── providers.tf               # AWS provider and backend configuration
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output definitions
│   └── versions.tf                # Terraform version constraints
├── screenshots/                   # Documentation screenshots and blog content
└── README.md                      # This file
```

## 🛠️ Setup Instructions

### Step 1: Create GitHub OIDC Identity Provider in AWS

1. Navigate to AWS IAM Console → Identity Providers
2. Create a new Identity Provider with:
   - **Provider type**: OpenID Connect
   - **Provider URL**: `https://token.actions.githubusercontent.com`
   - **Audience**: `sts.amazonaws.com`

### Step 2: Create IAM Role for GitHub Actions

1. Create a new IAM Role with "Custom trust policy"
2. Use the following trust policy (replace with your account ID and repository):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:your-username/aws-github-oidc:*"
        }
      }
    }
  ]
}
```

3. Attach appropriate permissions (e.g., `AmazonS3FullAccess` for this demo)
4. Name the role according to your environment (e.g., `github-oidc-dev-role`)

### Step 3: Configure GitHub Environment

1. Go to your repository → Settings → Environments
2. Create environment (e.g., `dev`)
3. Add the following secrets and variables:

**Secrets:**

- `AWS_DEPLOYMENT_ROLE`: ARN of the IAM role created in Step 2

**Variables:**

- `AWS_REGION`: Your target AWS region
- `TF_S3_BACKEND_BUCKET_NAME`: S3 bucket name for Terraform state

### Step 4: Prepare Terraform Backend

Ensure you have an S3 bucket for Terraform state storage in your target AWS account.

## 🚀 Usage

### Deploy Infrastructure

1. Navigate to Actions tab in your GitHub repository
2. Select "Deploy Terraform" workflow
3. Click "Run workflow"
4. Choose your target environment (dev/test/prod)
5. Review the Terraform plan in the generated GitHub Issue
6. Approve the deployment to proceed

### Workflow Process

1. **Checkout**: Code is checked out from the repository
2. **Setup**: Terraform is installed and AWS credentials are configured via OIDC
3. **Initialize**: Terraform backend is initialized with environment-specific state
4. **Validate**: Terraform configuration is validated
5. **Plan**: Terraform plan is generated and saved
6. **Approval**: Manual approval is requested via GitHub Issue
7. **Apply**: Upon approval, Terraform applies the changes

## 🔧 Terraform Configuration

The Terraform configuration creates a simple S3 bucket with environment-specific naming:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "github-oidc-demo-${data.aws_caller_identity.current.account_id}-${var.environmentSuffix}"
}
```

Environment-specific variables are managed through `.tfvars` files in the `terraform/env/` directory.

## 🌍 Multi-Account Setup

To deploy to multiple AWS accounts:

1. **Repeat Steps 1 & 2** in each target AWS account
2. **Create separate GitHub environments** for each account (dev, test, prod)
3. **Configure environment-specific secrets and variables** for each environment
4. **Run the workflow** selecting the appropriate environment

## 🔒 Security Best Practices

- **Least Privilege**: IAM roles have minimal required permissions
- **Environment Isolation**: Separate roles and accounts for each environment
- **Temporary Credentials**: No long-lived AWS keys stored anywhere
- **Audit Trail**: All deployments are logged and traceable
- **Manual Approval**: Critical deployments require explicit approval

## 📝 Blog Post

For a detailed walkthrough of this setup, check out the complete blog post on Medium: [Secure Multi-Environment AWS Deployments from GitHub Actions Using OIDC](https://medium.com/@jayaganesh.krishnamoorthy/secure-multi-environment-aws-deployments-from-github-actions-using-oidc-e44975404e92)

---

**Happy deploying! 🚀**

For questions or issues, please open a GitHub issue or refer to the detailed blog post included in this repository.
