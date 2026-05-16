# API Documentation

## Base URL
```
https://api.learning-platform.example.com
```

## Authentication

All API endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "user_id": "user123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": "user123"
}
```

## TTS Service

### Generate Speech
```http
POST /api/tts/generate
Content-Type: application/json

{
  "text": "Hello, this is a test",
  "language": "en"
}
```

Response:
```json
{
  "audio_id": "uuid-here",
  "s3_key": "audio/user123/uuid-here.mp3",
  "download_url": "/api/tts/audio/uuid-here"
}
```

### Get Audio
```http
GET /api/tts/audio/{audio_id}
```

### Get History
```http
GET /api/tts/history
```

## STT Service

### Transcribe Audio
```http
POST /api/stt/transcribe
Content-Type: multipart/form-data

audio: <file>
language: en-US
```

Response:
```json
{
  "transcription_id": "uuid-here",
  "text": "Transcribed text here",
  "language": "en-US"
}
```

### Get Transcriptions
```http
GET /api/stt/transcriptions
```

## Chat Service

### Send Message
```http
POST /api/chat/message
Content-Type: application/json

{
  "message": "What is machine learning?",
  "conversation_id": "optional-conversation-id"
}
```

Response:
```json
{
  "conversation_id": "uuid-here",
  "response": "AI response here"
}
```

### Get Conversations
```http
GET /api/chat/conversations
```

### Get Conversation History
```http
GET /api/chat/conversations/{conversation_id}
```

### Delete Conversation
```http
DELETE /api/chat/conversations/{conversation_id}
```

## Document Service

### Upload Document
```http
POST /api/documents/upload
Content-Type: multipart/form-data

document: <file>
```

Response:
```json
{
  "document_id": "uuid-here",
  "notes_id": "uuid-here",
  "filename": "document.pdf"
}
```

### Get Document
```http
GET /api/documents/{document_id}
```

### Get Notes
```http
GET /api/documents/{document_id}/notes
```

### List Documents
```http
GET /api/documents
```

## Quiz Service

### Generate Quiz
```http
POST /api/quiz/generate
Content-Type: application/json

{
  "document_id": "uuid-here",
  "notes_id": "uuid-here",
  "num_questions": 5
}
```

Response:
```json
{
  "quiz_id": "uuid-here",
  "questions": [...]
}
```

### Get Quiz
```http
GET /api/quiz/{quiz_id}
```

### Submit Quiz
```http
POST /api/quiz/{quiz_id}/submit
Content-Type: application/json

{
  "answers": [0, 1, 2, 0, 1]
}
```

Response:
```json
{
  "submission_id": "uuid-here",
  "score": 80.0,
  "correct": 4,
  "total": 5,
  "feedback": [...]
}
```

### Get Quiz History
```http
GET /api/quiz/history
```

## Health Checks

All services provide a health check endpoint:

```http
GET /health
```

Response:
```json
{
  "status": "healthy",
  "service": "service-name"
}
```

