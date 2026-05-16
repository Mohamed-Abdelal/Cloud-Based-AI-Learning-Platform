#!/bin/bash
# Phase 2: Kafka and Microservices Deployment Script

set -e

echo "=========================================="
echo "Phase 2: Kafka & Microservices Deployment"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed!${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed!${NC}"
    exit 1
fi

# Check environment variables
REQUIRED_VARS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_REGION")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo -e "${RED}Missing required environment variables:${NC}"
    printf '%s\n' "${MISSING_VARS[@]}"
    echo ""
    echo -e "${YELLOW}Set them with:${NC}"
    echo "export AWS_ACCESS_KEY_ID=your-key"
    echo "export AWS_SECRET_ACCESS_KEY=your-secret"
    echo "export AWS_REGION=us-east-1"
    exit 1
fi

# Deploy Kafka
echo -e "${YELLOW}Deploying Kafka cluster...${NC}"
cd ../../kafka
docker-compose up -d

echo -e "${YELLOW}Waiting for Kafka to be ready (30 seconds)...${NC}"
sleep 30

# Create topics
echo -e "${YELLOW}Creating Kafka topics...${NC}"
chmod +x create-topics.sh
./create-topics.sh

echo -e "${GREEN}Kafka cluster deployed!${NC}"

# Deploy services
echo -e "${YELLOW}Deploying microservices...${NC}"
cd ../docker

# Check for .env file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cat > .env << EOF
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
JWT_SECRET=${JWT_SECRET:-your-secret-key-change-in-production}
EOF
fi

docker-compose up -d

echo -e "${YELLOW}Waiting for services to start (20 seconds)...${NC}"
sleep 20

# Health checks
echo -e "${YELLOW}Checking service health...${NC}"

SERVICES=("api-gateway:8080" "tts-service" "stt-service" "chat-service" "document-service" "quiz-service")

for service in "${SERVICES[@]}"; do
    if [[ $service == *":"* ]]; then
        IFS=':' read -r name port <<< "$service"
        if curl -s -f "http://localhost:${port}/health" > /dev/null; then
            echo -e "${GREEN}✓ ${name} is healthy${NC}"
        else
            echo -e "${RED}✗ ${name} health check failed${NC}"
        fi
    else
        # Check via docker
        if docker ps | grep -q "$service"; then
            echo -e "${GREEN}✓ ${service} is running${NC}"
        else
            echo -e "${RED}✗ ${service} is not running${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}=========================================="
echo -e "Phase 2 Deployment Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${YELLOW}Services are available at:${NC}"
echo "  - API Gateway: http://localhost:8080"
echo "  - Kong Gateway: http://localhost:8000"
echo "  - Kafka UI: http://localhost:8080 (if configured)"
echo ""
echo -e "${YELLOW}Test the API:${NC}"
echo "curl http://localhost:8080/health"

