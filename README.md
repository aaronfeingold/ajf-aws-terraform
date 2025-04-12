# AJF AWS Terraform Infrastructure

This repository contains Terraform configurations for managing AWS infrastructure for AJF Apps.

## Prerequisites

- Terraform v1.11.4 or later (on linux_amd64)
- AWS CLI configured with appropriate credentials
- Access to AWS account in us-east-1 region
- Terraform installed (see installation instructions below)

## Installation

### Installing Terraform on Fedora

For Fedora 39 the HashiCorp repository may not work correctly. Here's how to install Terraform manually:

1. Create a bin directory in your home folder if it doesn't exist:
   ```bash
   mkdir -p ~/bin
   ```

2. Get the latest Terraform version and download it:
   ```bash
   TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
   wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
   unzip terraform_${TER_VER}_linux_amd64.zip -d ~/bin
   ```

3. Make sure ~/bin is in your PATH:
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. Verify the installation:
   ```bash
   terraform --version
   ```

Note: This method is particularly useful for Fedora 39 and newer versions where the HashiCorp repository might not work correctly.
- It should work with dnf for Fedora 40 and 41. This developer has yet to test that out though.

## Project Structure

```
.
├── environments/
│   ├── dev/              # Development environment (planned)
│   ├── staging/          # Staging environment (planned)
│   └── prod/             # Production environment (active)
│       ├── main.tf       # Main configuration
│       ├── provider.tf   # AWS provider settings
│       └── backend.tf    # State backend configuration
├── modules/
│   ├── api/              # API Gateway module
│   ├── data/             # Data sources module
│   ├── ecr_existing/     # ECR repositories module
│   ├── lambda_existing/  # Lambda functions module
│   ├── parameters/       # SSM parameters module
│   ├── step_function/    # Step Functions module
│   ├── storage_existing/ # S3 buckets module
│   └── terraform_state/  # Terraform state management
```

## Usage

1. Navigate to the production environment directory:
   ```bash
   cd environments/prod
   ```

2. Create a `prod.tfvars` file based on the example template:
   ```bash
   cp prod.tfvars.example prod.tfvars
   ```

3. Edit `prod.tfvars` with your actual AWS account ID and application configurations.

4. Initialize Terraform (provide your actual terraform state bucket name):
   ```bash
   terraform init -backend-config="bucket=your-actual-terraform-state-bucket"
   ```
   Note: The bucket name is not stored in git for security reasons. You must provide it during initialization.

5. Plan the changes:
   ```bash
   terraform plan -var-file=prod.tfvars
   ```

6. Apply the changes:
   ```bash
   terraform apply -var-file=prod.tfvars
   ```


## Security

All resources are configured with appropriate security settings:
- S3 buckets have encryption enabled
- IAM roles follow least privilege principle
- API Gateway has proper authentication and authorization

## State Management

Terraform state is stored in an S3 bucket with versioning enabled and state locking using DynamoDB.

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` to format the code
4. Run `terraform validate` to check for errors
5. Submit a pull request
