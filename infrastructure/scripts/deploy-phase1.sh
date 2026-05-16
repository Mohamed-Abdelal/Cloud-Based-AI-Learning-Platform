#!/bin/bash
# Phase 1 Infrastructure Deployment Script

set -e  # Exit on error

echo "=========================================="
echo "Phase 1: AWS Infrastructure Deployment"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials not configured. Run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites check passed!${NC}"

# Get AWS account info
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo -e "${YELLOW}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"

# Navigate to Terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${RED}Please edit terraform.tfvars with your values before continuing!${NC}"
    echo -e "${YELLOW}Required values:${NC}"
    echo "  - aws_region"
    echo "  - key_name (EC2 Key Pair name)"
    echo "  - db_password (strong password)"
    read -p "Press Enter after editing terraform.tfvars..."
fi

# Check for required variables
source terraform.tfvars 2>/dev/null || true

if [ -z "$key_name" ]; then
    echo -e "${RED}key_name not set in terraform.tfvars${NC}"
    exit 1
fi

# Verify EC2 Key Pair exists
echo -e "${YELLOW}Verifying EC2 Key Pair: ${key_name}${NC}"
if ! aws ec2 describe-key-pairs --key-names "$key_name" &> /dev/null; then
    echo -e "${RED}EC2 Key Pair '${key_name}' not found!${NC}"
    echo -e "${YELLOW}Please create it in AWS Console or run:${NC}"
    echo "aws ec2 create-key-pair --key-name ${key_name} --query 'KeyMaterial' --output text > ${key_name}.pem"
    exit 1
fi

echo -e "${GREEN}EC2 Key Pair verified!${NC}"

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init

# Validate Terraform configuration
echo -e "${YELLOW}Validating Terraform configuration...${NC}"
if ! terraform validate; then
    echo -e "${RED}Terraform validation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Validation passed!${NC}"

# Plan deployment
echo -e "${YELLOW}Creating Terraform execution plan...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo -e "${YELLOW}Review the plan above.${NC}"
read -p "Do you want to proceed with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# Apply Terraform
echo -e "${YELLOW}Deploying infrastructure...${NC}"
terraform apply tfplan

# Save outputs
echo -e "${YELLOW}Saving outputs...${NC}"
terraform output -json > ../outputs.json
terraform output > ../outputs.txt

echo -e "${GREEN}=========================================="
echo -e "Phase 1 Deployment Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${YELLOW}Important outputs saved to:${NC}"
echo "  - infrastructure/outputs.json"
echo "  - infrastructure/outputs.txt"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the outputs to get RDS endpoints and S3 bucket names"
echo "2. Update service configurations with these values"
echo "3. Proceed to Phase 2: Kafka and Microservices deployment"

