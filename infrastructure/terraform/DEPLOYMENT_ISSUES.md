# Deployment Issues and Workarounds

## Issues Encountered During Deployment

### 1. IAM Access Restrictions
**Issue**: User account cannot create IAM roles/policies
**Workaround**: Lambda functions and IAM roles are commented out in Terraform. The IAM Design Document demonstrates the theoretical implementation.

### 2. S3 Bucket Policy Restrictions
**Issue**: User account has restricted S3 permissions (cannot set bucket policies, versioning, encryption)
**Workaround**: S3 buckets are created but advanced configurations are commented out. Security is enforced via:
- Security Groups (network-level)
- VPC Endpoints (private S3 access)
- Application-level authentication (JWT)

### 3. PostgreSQL Version
**Issue**: PostgreSQL 15.4 doesn't exist
**Fix**: Changed to PostgreSQL 15.3

### 4. HTTPS Certificate
**Issue**: HTTPS listener requires SSL certificate
**Workaround**: HTTPS listener is commented out. HTTP listener is active. For production, obtain ACM certificate and uncomment HTTPS configuration.

## Resources Successfully Deployed

- VPC with subnets (public, private, data, Kafka)
- Network ACLs
- Security Groups
- NAT Gateways
- Internet Gateway
- VPC Endpoints (S3)
- S3 Buckets (basic creation)
- RDS Instances (PostgreSQL 15.3)
- EC2 Instances (Kafka brokers, Zookeeper, Container hosts)
- Application Load Balancer (HTTP only)
- Target Groups
- Auto Scaling Groups
- CloudWatch Alarms

## Resources Commented Out

- Lambda functions (require IAM roles)
- IAM roles and policies
- HTTPS listener and rules
- S3 bucket policies
- S3 bucket versioning
- S3 bucket encryption configurations
- S3 bucket lifecycle policies

## Next Steps

1. For production deployment:
   - Obtain SSL certificate via ACM
   - Uncomment HTTPS listener configuration
   - Request IAM permissions or use alternative authentication
   - Configure S3 bucket policies if permissions allow

2. For development/testing:
   - Current configuration is sufficient
   - Use HTTP endpoints
   - Security enforced via Security Groups and application-level auth

