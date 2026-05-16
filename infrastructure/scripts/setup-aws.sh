#!/bin/bash
# AWS Setup and Configuration Script

set -e

echo "=========================================="
echo "AWS Account Setup and Configuration"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed!${NC}"
    echo -e "${YELLOW}Install it from: https://aws.amazon.com/cli/${NC}"
    exit 1
fi

# Configure AWS credentials
echo -e "${YELLOW}Configuring AWS credentials...${NC}"
echo "You'll need:"
echo "  - AWS Access Key ID"
echo "  - AWS Secret Access Key"
echo "  - Default region (e.g., us-east-1)"
echo "  - Default output format (json)"
echo ""

read -p "Do you want to configure AWS CLI now? (yes/no): " configure

if [ "$configure" == "yes" ]; then
    aws configure
fi

# Verify credentials
echo -e "${YELLOW}Verifying AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials verification failed!${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo -e "${GREEN}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${GREEN}AWS Region: ${AWS_REGION}${NC}"

# Create EC2 Key Pair
echo ""
echo -e "${YELLOW}EC2 Key Pair Setup${NC}"
read -p "Enter a name for your EC2 Key Pair (or press Enter to skip): " key_name

if [ -n "$key_name" ]; then
    if aws ec2 describe-key-pairs --key-names "$key_name" &> /dev/null; then
        echo -e "${YELLOW}Key Pair '${key_name}' already exists.${NC}"
    else
        echo -e "${YELLOW}Creating EC2 Key Pair: ${key_name}${NC}"
        aws ec2 create-key-pair \
            --key-name "$key_name" \
            --query 'KeyMaterial' \
            --output text > "${key_name}.pem"
        
        chmod 400 "${key_name}.pem"
        echo -e "${GREEN}Key Pair created! Private key saved to: ${key_name}.pem${NC}"
        echo -e "${RED}Keep this file secure and never commit it to git!${NC}"
    fi
fi

# Create S3 bucket for Terraform state (optional)
echo ""
echo -e "${YELLOW}Terraform State Bucket (Optional)${NC}"
read -p "Do you want to create an S3 bucket for Terraform state? (yes/no): " create_bucket

if [ "$create_bucket" == "yes" ]; then
    read -p "Enter bucket name (must be globally unique): " bucket_name
    
    if aws s3 ls "s3://${bucket_name}" 2>&1 | grep -q 'NoSuchBucket'; then
        echo -e "${YELLOW}Creating S3 bucket: ${bucket_name}${NC}"
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
        
        # Enable versioning
        aws s3api put-bucket-versioning \
            --bucket "$bucket_name" \
            --versioning-configuration Status=Enabled
        
        # Enable encryption
        aws s3api put-bucket-encryption \
            --bucket "$bucket_name" \
            --server-side-encryption-configuration '{
                "Rules": [{
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }]
            }'
        
        echo -e "${GREEN}Bucket created! Update terraform backend configuration.${NC}"
    else
        echo -e "${YELLOW}Bucket already exists.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=========================================="
echo -e "AWS Setup Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update terraform.tfvars with your key_name"
echo "2. Run: ./deploy-phase1.sh"

