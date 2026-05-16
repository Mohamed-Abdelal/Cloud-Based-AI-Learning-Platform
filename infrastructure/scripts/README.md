# Deployment Scripts

## Scripts Overview

1. **setup-aws.sh** - Initial AWS account setup and configuration
2. **deploy-phase1.sh** - Deploy Phase 1 infrastructure (VPC, EC2, S3, RDS, etc.)
3. **deploy-phase2.sh** - Deploy Phase 2 (Kafka and microservices)
4. **destroy-infrastructure.sh** - Destroy all infrastructure (use with caution!)

## Usage

### Step 1: Setup AWS
```bash
chmod +x infrastructure/scripts/*.sh
./infrastructure/scripts/setup-aws.sh
```

### Step 2: Deploy Phase 1
```bash
./infrastructure/scripts/deploy-phase1.sh
```

### Step 3: Deploy Phase 2
```bash
./infrastructure/scripts/deploy-phase2.sh
```

### Cleanup (if needed)
```bash
./infrastructure/scripts/destroy-infrastructure.sh
```

## Prerequisites

- AWS CLI installed and configured
- Terraform >= 1.0
- Docker and Docker Compose
- Bash shell

## Environment Variables

Set these before running Phase 2:
```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_REGION=us-east-1
export OPENAI_API_KEY=your-openai-key
export JWT_SECRET=your-secret-key
```

## Windows Users

If you're on Windows, you can use:
- Git Bash
- WSL (Windows Subsystem for Linux)
- PowerShell (scripts need to be converted)

Or run the commands manually following the script logic.

