#!/bin/bash
# Infrastructure Destruction Script (Use with Caution!)

set -e

echo "=========================================="
echo "WARNING: Infrastructure Destruction"
echo "=========================================="

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}This will DESTROY all infrastructure!${NC}"
echo -e "${YELLOW}This action cannot be undone!${NC}"
echo ""
read -p "Type 'DESTROY' to confirm: " confirm

if [ "$confirm" != "DESTROY" ]; then
    echo -e "${GREEN}Destruction cancelled.${NC}"
    exit 0
fi

# Navigate to Terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Destroy infrastructure
echo -e "${YELLOW}Destroying infrastructure...${NC}"
terraform destroy -auto-approve

echo -e "${GREEN}Infrastructure destroyed!${NC}"

