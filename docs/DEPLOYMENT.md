# Deployment Guide

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- Docker & Docker Compose
- AWS CLI configured
- kubectl (if using Kubernetes)

## Phase 1: Infrastructure Deployment

### 1. Configure Terraform

```bash
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure S3 Bucket Policies

After infrastructure is deployed, apply bucket policies:

```bash
# Update bucket policies in modules/s3/bucket-policies.tf
terraform apply
```

## Phase 2: Kafka Cluster Setup

### 1. Deploy Kafka Cluster

```bash
cd kafka
docker-compose up -d
```

### 2. Create Topics

```bash
chmod +x create-topics.sh
./create-topics.sh
```

## Phase 3: Service Deployment

### Option A: Docker Compose (Development)

```bash
cd docker
docker-compose up -d
```

### Option B: Kubernetes (Production)

```bash
# Build and push images
docker build -t your-registry/api-gateway:latest services/api-gateway/
docker push your-registry/api-gateway:latest

# Apply Kubernetes manifests
kubectl apply -f k8s/
```

## Environment Variables

Set the following environment variables:

```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_REGION=us-east-1
export OPENAI_API_KEY=your-openai-key
export JWT_SECRET=your-jwt-secret
```

## Database Initialization

Databases are automatically initialized using the `init_db.sql` files in each service directory.

## Verification

1. Check service health:
```bash
curl http://localhost:8080/health
```

2. Test authentication:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test-user"}'
```

3. Verify Kafka topics:
```bash
docker exec -it kafka-1 kafka-topics --list --bootstrap-server localhost:9092
```

## Troubleshooting

### Services not starting
- Check Docker logs: `docker-compose logs <service-name>`
- Verify environment variables
- Check database connectivity

### Kafka connection issues
- Verify Kafka brokers are running
- Check network connectivity
- Verify topic creation

### S3 access issues
- Verify bucket policies
- Check Security Groups
- Verify VPC Endpoints

## Production Considerations

1. Use AWS Secrets Manager for credentials
2. Enable Multi-AZ for RDS
3. Configure Auto Scaling
4. Set up CloudWatch monitoring
5. Enable WAF on ALB
6. Use HTTPS certificates from ACM
7. Implement backup strategies
8. Set up disaster recovery procedures

