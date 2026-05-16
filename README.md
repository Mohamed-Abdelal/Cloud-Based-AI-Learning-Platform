<div align="center">
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/Apache_Kafka-231F20?style=for-the-badge&logo=apache-kafka&logoColor=white" alt="Kafka" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Kong-003459?style=for-the-badge&logo=kong&logoColor=white" alt="Kong Gateway" />
  <img src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB" alt="React" />
</div>

<h1 align="center">Cloud-Based AI Learning Platform</h1>

<p align="center">
  <b>An enterprise-grade, event-driven microservices platform leveraging AI for educational services.</b><br/>
  Designed and deployed on AWS with Infrastructure as Code and robust security.
</p>

## 🚀 Project Overview

The **Cloud-Based AI Learning Platform** is a highly scalable, full-stack, cloud-native application. It provides an intelligent, interconnected suite of educational tools. Users can upload documents to have them automatically summarized, generate dynamic quizzes based on their materials, transcribe audio lectures, and interact with a conversational AI assistant that understands their uploaded content.

Built strictly around enterprise design patterns, this repository showcases a **fully decoupled microservices architecture**. It utilizes **FastAPI** for high-performance Python backends, **Apache Kafka** for asynchronous event-driven communication, **Kong API Gateway** for edge security, and **Terraform** for automated AWS infrastructure provisioning.

---

## 🏗️ System Architecture

This project was engineered to avoid the pitfalls of monolithic applications by enforcing strict domain boundaries and storage isolation.

### The Request Flow
1. **Frontend**: The user interacts with a modern React SPA (Single Page Application).
2. **API Gateway (Kong)**: All traffic hits the Kong Gateway, which acts as a reverse proxy, handling CORS, rate limiting, and stateless **JWT Authentication**.
3. **Microservices (FastAPI)**: Traffic is routed to one of six independent, containerized backend services.
4. **Storage Isolation**: Each service communicates with its *own dedicated PostgreSQL database* and its *own S3 Bucket*. No two services share a database, preventing tight coupling and data leaks.
5. **Event Streaming (Kafka)**: When a service completes a task (e.g., a document is processed), it publishes an event to a **3-Node Apache Kafka Cluster** (managed by a 3-Node Zookeeper ensemble). Other services consume these events asynchronously to trigger downstream workflows (e.g., automatically generating a quiz from the document notes).

---

## ⚙️ Microservices Ecosystem

The backend is composed of 6 independent domains, each running its own FastAPI server:

#### 1. 🛡️ User Service (`user-service`)
Handles user registration, login, and secure password hashing via bcrypt. Issues stateless JWT tokens that are utilized by the Kong API Gateway for route protection.
- **Database**: `user_db` (PostgreSQL)

#### 2. 📄 Document Service (`document-service`)
Accepts PDF document uploads, extracts text, and utilizes the DeepSeek AI API to generate concise educational summaries and notes.
- **Database**: `document_db` (PostgreSQL)
- **Storage**: Isolated S3 Bucket for PDFs and generated notes.
- **Events**: Publishes `document.processed` and `notes.generated`.

#### 3. 🧠 Quiz Service (`quiz-service`)
Dynamically generates multiple-choice quizzes based on either user-provided topics or the context of recently uploaded documents. Scores user submissions and tracks history.
- **Database**: `quiz_db` (PostgreSQL)
- **Storage**: Isolated S3 Bucket for quiz JSON metadata.
- **Events**: Consumes `notes.generated` to build relevant questions.

#### 4. 💬 Chat Service (`chat-service`)
A conversational AI assistant that leverages the DeepSeek API. It consumes document events via Kafka to build a "knowledge base," allowing users to chat directly with their uploaded study materials.
- **Database**: `chat_db` (PostgreSQL)
- **Events**: Consumes `document.processed`.

#### 5. 🎙️ Speech-to-Text Service (`stt-service`)
Allows users to upload audio files (e.g., recorded lectures) and transcribes them into text using Google Speech Recognition algorithms.
- **Storage**: Isolated S3 bucket for audio uploads.
- **Events**: Publishes `audio.transcription.completed`.

#### 6. 🔊 Text-to-Speech Service (`tts-service`)
Converts textual study notes or generated quizzes into downloadable MP3 audio files using the `gTTS` engine, aiding auditory learners.
- **Storage**: Isolated S3 bucket for generated MP3s.

---

## 🛠️ Technology Stack

| Domain | Technologies |
| :--- | :--- |
| **Cloud Provider** | AWS (VPC, EC2, S3, RDS, Lambda, ALB, EBS) |
| **Infrastructure as Code** | Terraform |
| **Event Streaming** | Apache Kafka, Zookeeper |
| **API Gateway** | Kong Gateway |
| **Containerization** | Docker, Docker Compose |
| **Backend Services** | Python, FastAPI, SQLAlchemy, Pydantic |
| **Frontend** | React, Vite |
| **Databases** | PostgreSQL (Amazon RDS) |

---

## 📁 Repository Structure

```text
.
├── frontend/                 # React-based User Interface
├── infrastructure/           # Complete AWS Infrastructure (Terraform)
│   ├── terraform/           # IaC modules (VPC, S3, EC2, RDS, Lambda, ALB)
│   └── scripts/             # Infrastructure setup scripts
├── services/                 # Backend Microservices Ecosystem
│   ├── api-gateway/         # Kong Gateway configuration
│   ├── tts-service/         # Text-to-Speech Processing
│   ├── stt-service/         # Speech-to-Text Processing
│   ├── chat-service/        # Conversational AI capabilities
│   ├── document-service/    # AI-powered Document parsing
│   ├── quiz-service/        # Dynamic Quiz Generation
│   └── user-service/        # Identity and Access Management
├── kafka/                    # Event streaming setup scripts
├── docker/                   # Massive multi-container orchestration (docker-compose)
└── docs/                     # Technical documentation & architecture diagrams
```

---

## 🔒 Security Implementation

Security is a first-class citizen in this repository:
- **No Hardcoded Secrets**: All AI API keys (DeepSeek/OpenAI), AWS Credentials, and JWT signature keys are strictly loaded via environment variables.
- **CORS Hardening**: Cross-Origin Resource Sharing is strictly controlled via environment configurations, preventing unauthorized domain access to the microservices.
- **Network Isolation**: Deployed across Public, Private, Data, and Kafka subnets within a custom AWS VPC.
- **Access Control**: Least-privilege Security Groups, Network ACLs, and restrictive S3 Bucket Policies.

---

## 🚦 Quick Start Guide

### 1. Environment Configuration
Navigate to the `docker/` folder, copy the example environment file, and fill in your API keys:
```bash
cd docker
cp .env.example .env
# Edit .env and insert your DeepSeek API key and JWT secret
```

### 2. Local Cluster Deployment
You can spin up the entire enterprise architecture locally using Docker Compose. This will launch 4 Postgres Databases, 3 Zookeeper Nodes, 3 Kafka Brokers, Kong Gateway, and the 6 FastAPI services.
```bash
cd docker
docker-compose up -d
```

### 3. Provision Cloud Infrastructure (Optional)
To deploy the raw infrastructure to AWS:
```bash
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
# Update AWS credentials and variables in terraform.tfvars
terraform init
terraform apply
```

---

## 📖 Documentation

For deep-dive technical documentation, including API specs and architecture diagrams, please explore the `/docs` directory.

- [Architecture Documentation](./docs/ARCHITECTURE.md)

---

<div align="center">
  <i>Developed to showcase advanced cloud engineering, microservices architecture, and secure Python development practices.</i>
</div>
