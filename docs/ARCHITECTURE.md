# Architecture Documentation

## System Architecture

```
                    ┌─────────────┐
                    │   Clients   │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  API Gateway │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐      ┌─────▼─────┐      ┌────▼────┐
   │   TTS   │      │    STT    │      │  Chat   │
   │ Service │      │  Service  │      │ Service │
   └────┬────┘      └─────┬─────┘      └────┬────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Kafka     │
                    │   Cluster   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐      ┌─────▼─────┐      ┌────▼────┐
   │Document │      │   Quiz    │      │  Other  │
   │ Service │      │  Service  │      │Services │
   └─────────┘      └───────────┘      └─────────┘
```

## Component Overview

### API Gateway
- Single entry point for all requests
- JWT-based authentication
- Request routing to services
- Rate limiting and throttling

### Microservices

#### TTS Service
- Converts text to speech
- Stores audio in S3
- Publishes `audio.generation.completed` events

#### STT Service
- Transcribes audio to text
- Stores transcriptions in database
- Publishes `audio.transcription.completed` events

#### Chat Service
- Conversational AI
- Maintains conversation context
- Consumes document events for knowledge base

#### Document Service
- Processes PDF, DOCX, TXT files
- Generates notes using AI
- Publishes `document.processed` and `notes.generated` events

#### Quiz Service
- Generates quizzes from documents
- Stores user responses
- Consumes `notes.generated` events

## Data Flow

### Document Processing Flow
1. User uploads document → Document Service
2. Document Service extracts text
3. Document Service generates notes
4. Document Service publishes `document.processed` event
5. Quiz Service consumes event
6. User requests quiz generation
7. Quiz Service generates quiz from notes

### Audio Processing Flow
1. User requests TTS → TTS Service
2. TTS Service generates audio
3. Audio stored in S3
4. TTS Service publishes `audio.generation.completed`
5. User uploads audio for transcription → STT Service
6. STT Service transcribes
7. STT Service publishes `audio.transcription.completed`

## Storage Architecture

### S3 Buckets (Isolated per Service)
- `tts-service-storage-{env}`: Generated audio files
- `stt-service-storage-{env}`: Uploaded audio files
- `chat-service-storage-{env}`: Conversation archives
- `document-reader-storage-{env}`: Documents and notes
- `quiz-service-storage-{env}`: Quiz templates

### RDS Databases (Isolated per Service)
- User Management DB: User accounts
- Chat Service DB: Conversation metadata
- Document Service DB: Document metadata
- Quiz Service DB: Quiz definitions and responses
- TTS/STT Service DBs: Request metadata

## Security Architecture

### Network Security
- VPC with public/private/data subnets
- Security Groups for service isolation
- NAT Gateways for private subnet access
- VPC Endpoints for S3 access

### Access Control
- Security Groups (replacing IAM roles)
- S3 Bucket Policies
- JWT authentication at API Gateway
- Database-level access control

### Data Security
- Encryption at rest (S3, EBS, RDS)
- Encryption in transit (TLS 1.3)
- Separate encryption keys per service
- Secrets management

## Event-Driven Architecture

### Kafka Topics
- `document.uploaded`: Document upload events
- `document.processed`: Document processing complete
- `notes.generated`: Notes generation complete
- `quiz.requested`: Quiz generation request
- `quiz.generated`: Quiz generation complete
- `audio.transcription.requested`: STT request
- `audio.transcription.completed`: STT complete
- `audio.generation.requested`: TTS request
- `audio.generation.completed`: TTS complete
- `chat.message`: Chat interactions

### Event Patterns
- Event Sourcing: State changes as events
- CQRS: Separate read/write operations
- Saga Pattern: Distributed transactions
- Event Notification: Service notifications

## Scalability

### Horizontal Scaling
- Auto Scaling Groups for EC2
- Container orchestration (Kubernetes/Docker Swarm)
- Load balancers for traffic distribution
- Kafka partitioning for parallel processing

### Vertical Scaling
- RDS instance scaling
- EBS volume expansion
- Lambda memory configuration

## Monitoring and Observability

### CloudWatch
- EC2 instance metrics
- RDS performance metrics
- Lambda execution metrics
- S3 access logs

### Application Logs
- Service-level logging
- Request/response logging
- Error tracking
- Performance metrics

## Disaster Recovery

### Backup Strategy
- RDS automated backups (7-day retention)
- EBS snapshots
- S3 versioning
- Database exports

### Recovery Procedures
- RDS point-in-time recovery
- EBS snapshot restoration
- S3 object restoration
- Service failover procedures

