# Quick Start (TA Demo)

Use this to bring the stack up fast if your session resets.

## One-time prep
1. Copy `.env.example` to `.env` and fill real secrets if needed (otherwise defaults use local Postgres and Kafka inside compose).
2. Ensure Docker Desktop is running.

## Start services
```powershell
cd "C:\Users\YoussefB\Documents\Cloud\docker"
docker compose up -d
```

## Health checks
```powershell
# API Gateway
Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing

# Service health (all should be healthy)
docker compose ps
```

## Kafka topics (only if needed)
```powershell
cd "C:\Users\YoussefB\Documents\Cloud\kafka"
./create-topics.sh
```

## Stopping (keep volumes/data)
```powershell
cd "C:\Users\YoussefB\Documents\Cloud\docker"
docker compose down
```

## Notes
- Images are already built; `docker compose up -d` will reuse them.
- Postgres data persists via docker volumes; no need to re-seed unless volumes are removed.
- If you need to rebuild after code changes: `docker compose build && docker compose up -d`.
