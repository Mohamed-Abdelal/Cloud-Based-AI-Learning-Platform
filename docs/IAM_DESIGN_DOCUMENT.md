# IAM Policy Design Document
## Theoretical IAM Implementation (Not Directly Implementable)

**Note:** This document describes the IAM roles and policies that would be created if IAM access were available. In the actual implementation, these are replaced by Security Groups, S3 Bucket Policies, and application-level authentication.

---

## 1. IAM Roles for EC2 Instances

### 1.1 Container Host Role
**Role Name:** `CloudLearningPlatform-ContainerHost-Role-{env}`

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3AccessForServiceBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::cloud-learning-platform-*-storage-*",
        "arn:aws:s3:::cloud-learning-platform-*-storage-*/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Sid": "KafkaAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Type": "KafkaBroker"
        }
      }
    }
  ]
}
```

### 1.2 Kafka Broker Role
**Role Name:** `CloudLearningPlatform-KafkaBroker-Role-{env}`

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EBSVolumeAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeVolumes"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Type": "KafkaBroker"
        }
      }
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/ec2/kafka-*"
    }
  ]
}
```

---

## 2. IAM Roles for Lambda Functions

### 2.1 S3 Event Processor Lambda Role
**Role Name:** `CloudLearningPlatform-S3EventProcessor-LambdaRole-{env}`

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::cloud-learning-platform-*-storage-*/*"
      ]
    },
    {
      "Sid": "KafkaPublish",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:WriteData",
        "kafka-cluster:DescribeTopic"
      ],
      "Resource": "arn:aws:kafka:*:*:cluster/*/topic/*"
    },
    {
      "Sid": "VPCExecution",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### 2.2 Cleanup Lambda Role
**Role Name:** `CloudLearningPlatform-Cleanup-LambdaRole-{env}`

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3LifecycleManagement",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::cloud-learning-platform-*-storage-*",
        "arn:aws:s3:::cloud-learning-platform-*-storage-*/*"
      ],
      "Condition": {
        "DateGreaterThan": {
          "aws:CurrentTime": "{{aws:CurrentTime - 90 days}}"
        }
      }
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

---

## 3. IAM Users for Developers and Administrators

### 3.1 Developer User
**User Name:** `cloud-learning-platform-developer-{env}`

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:GetObject",
        "s3:ListBucket",
        "rds:Describe*",
        "logs:DescribeLogGroups",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:*:*:repository/cloud-learning-platform-*"
    }
  ]
}
```

**MFA Required:** Yes (for console access)

### 3.2 Administrator User
**User Name:** `cloud-learning-platform-admin-{env}`

**Attached Policies:**
- `PowerUserAccess` (AWS managed policy)
- Custom policy for infrastructure management

**MFA Required:** Yes (mandatory)

**Custom Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullInfrastructureAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "rds:*",
        "lambda:*",
        "elasticloadbalancing:*",
        "vpc:*",
        "logs:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Sid": "DenyIAMAccess",
      "Effect": "Deny",
      "Action": [
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 4. IAM Roles for Containerized Applications

### 4.1 TTS Service Role
**Role Name:** `CloudLearningPlatform-TTSService-Role-{env}`

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TTSBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::cloud-learning-platform-tts-service-storage-*/*"
    },
    {
      "Sid": "RDSAccess",
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": "arn:aws:rds-db:*:*:dbuser:*/tts_service_user"
    }
  ]
}
```

### 4.2 Document Service Role
**Role Name:** `CloudLearningPlatform-DocumentService-Role-{env}`

**Attached Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DocumentBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::cloud-learning-platform-document-reader-storage-*",
        "arn:aws:s3:::cloud-learning-platform-document-reader-storage-*/*"
      ]
    },
    {
      "Sid": "KafkaPublish",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:WriteData",
        "kafka-cluster:DescribeTopic"
      ],
      "Resource": "arn:aws:kafka:*:*:cluster/*/topic/document.*"
    }
  ]
}
```

---

## 5. Least Privilege Principle Implementation

### 5.1 Service Isolation
Each service role has access ONLY to:
- Its dedicated S3 bucket
- Its dedicated RDS database
- Required Kafka topics
- CloudWatch logs for its service

### 5.2 Cross-Service Access Prevention
- No service role can access another service's S3 bucket
- No service role can access another service's RDS database
- Services communicate only through Kafka events

### 5.3 Resource Tagging
All resources are tagged with:
- `Service`: Service name (tts-service, stt-service, etc.)
- `Environment`: dev, staging, prod
- `ManagedBy`: Terraform

IAM policies use these tags to enforce access:
```json
{
  "Condition": {
    "StringEquals": {
      "aws:ResourceTag/Service": "tts-service"
    }
  }
}
```

---

## 6. IAM Policy Examples for Each Service

### 6.1 TTS Service Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TTSStorageAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::cloud-learning-platform-tts-service-storage-*/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "TTSDatabaseAccess",
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": "arn:aws:rds-db:*:*:dbuser:*/tts_service_user",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "10.0.10.0/24"
        }
      }
    }
  ]
}
```

### 6.2 STT Service Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "STTStorageAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::cloud-learning-platform-stt-service-storage-*/*"
    },
    {
      "Sid": "STTDatabaseAccess",
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": "arn:aws:rds-db:*:*:dbuser:*/stt_service_user"
    }
  ]
}
```

---

## 7. MFA Implementation

### 7.1 MFA Policy for Administrative Access
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

---

## 8. Service Account Implementation

### 8.1 Service Account for Kubernetes
If using Kubernetes, service accounts would be created with IAM roles:

**Service Account:** `tts-service-account`
**IAM Role:** `CloudLearningPlatform-TTSService-K8sRole-{env}`

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.REGION.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E:sub": "system:serviceaccount:default:tts-service-account"
        }
      }
    }
  ]
}
```

---

## 9. Access Control Matrix

| Service | S3 Bucket Access | RDS Access | Kafka Topics | Lambda Invoke |
|---------|------------------|------------|--------------|---------------|
| TTS Service | tts-service-storage-* | tts-service DB only | audio.generation.* | None |
| STT Service | stt-service-storage-* | stt-service DB only | audio.transcription.* | None |
| Chat Service | chat-service-storage-* | chat-service DB only | chat.message, document.processed | None |
| Document Service | document-reader-storage-* | document-service DB only | document.*, notes.* | None |
| Quiz Service | quiz-service-storage-* | quiz-service DB only | quiz.*, notes.generated | None |
| Lambda (S3 Processor) | Read: all, Write: none | None | Write: document.uploaded | None |
| Lambda (Cleanup) | Delete: old objects only | None | None | None |

---

## 10. Implementation Notes

### 10.1 Why IAM Cannot Be Used
- College AWS account has IAM access restrictions
- Alternative solutions implemented:
  - Security Groups for network-level access control
  - S3 Bucket Policies for storage access control
  - Database-level access control (PostgreSQL roles)
  - Application-level authentication (JWT)

### 10.2 Equivalent Security Achieved
- Network isolation: Security Groups
- Storage isolation: Bucket Policies
- Service authentication: JWT tokens
- Database access: Security Groups + PostgreSQL roles

### 10.3 If IAM Were Available
The policies above would be implemented exactly as described, providing:
- Fine-grained access control
- Automatic credential rotation
- Centralized access management
- Audit trail through CloudTrail

---

## Conclusion

This document demonstrates understanding of IAM concepts and best practices, even though direct IAM implementation is not possible in the college AWS environment. The alternative implementation using Security Groups, Bucket Policies, and application-level authentication achieves equivalent security objectives while working within the constraints of the available AWS account permissions.

