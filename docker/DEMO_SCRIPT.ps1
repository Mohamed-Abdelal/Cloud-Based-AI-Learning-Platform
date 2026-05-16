# Demo script for TA runthrough
# Assumes Docker Desktop running, current directory is this file's folder.
# Uses env vars from .env (copy from .env.example and fill secrets).

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
$base = "http://localhost:8080"

function New-MultipartFormData {
  param(
    [Parameter(Mandatory = $true)] [string] $FilePath,
    [Parameter(Mandatory = $true)] [string] $FieldName,
    [Parameter(Mandatory = $true)] [string] $ContentType
  )

  $boundary = "----CloudDemoBoundary" + ([guid]::NewGuid().ToString("N"))
  $ms = New-Object System.IO.MemoryStream
  $sw = New-Object System.IO.StreamWriter($ms)
  $fileName = [IO.Path]::GetFileName($FilePath)

  $sw.Write("--$boundary`r`n")
  $sw.Write("Content-Disposition: form-data; name=`"$FieldName`"; filename=`"$fileName`"`r`n")
  $sw.Write("Content-Type: $ContentType`r`n`r`n")
  $sw.Flush()

  $fileBytes = [IO.File]::ReadAllBytes($FilePath)
  $ms.Write($fileBytes, 0, $fileBytes.Length)

  $sw.Write("`r`n--$boundary--`r`n")
  $sw.Flush()
  $ms.Position = 0

  return @{ Body = $ms.ToArray(); Boundary = $boundary }
}

Write-Host "Starting stack (local demo env)..." -ForegroundColor Cyan
docker compose --env-file ./.env.local-demo up -d | Out-Null

Write-Host "Waiting for services to be healthy..." -ForegroundColor Cyan
$maxTries = 15
for ($i = 1; $i -le $maxTries; $i++) {
  try {
    $h = Invoke-WebRequest -Uri "$base/health" -UseBasicParsing -TimeoutSec 5
    if ($h.StatusCode -eq 200) { Write-Host "Gateway healthy" -ForegroundColor Green; break }
  } catch { Write-Host "Health check retry $i/$maxTries" -ForegroundColor Yellow }
  Start-Sleep -Seconds 2
}

Write-Host "Login..." -ForegroundColor Cyan
$loginBody = @{ user_id = "demo-user" } | ConvertTo-Json
$loginResp = Invoke-WebRequest -Method POST -Uri "$base/api/auth/login" -UseBasicParsing -ContentType "application/json" -Body $loginBody
$token = ($loginResp.Content | ConvertFrom-Json).token
$headers = @{ Authorization = "Bearer $token" }

# Chat message
Write-Host "Chat message..." -ForegroundColor Cyan
$chatBody = @{ message = "Hello, generate a short reply."; conversation_id = $null } | ConvertTo-Json
Invoke-WebRequest -Method POST -Uri "$base/api/chat/message" -UseBasicParsing -ContentType "application/json" -Headers $headers -Body $chatBody

# TTS
Write-Host "TTS..." -ForegroundColor Cyan
$ttsBody = @{ text = "Welcome to the cloud learning platform demo." } | ConvertTo-Json
Invoke-WebRequest -Method POST -Uri "$base/api/tts/generate" -UseBasicParsing -ContentType "application/json" -Headers $headers -Body $ttsBody

# STT (uses sample.wav; prefers shared path if present)
$sharedWav = "C:\Users\YoussefB\Documents\Cloud\sample.wav"
$localWav = Join-Path $scriptDir "sample.wav"
$sampleWav = if (Test-Path $sharedWav) { $sharedWav } elseif (Test-Path $localWav) { $localWav } else { $null }
if ($sampleWav) {
  Write-Host "STT using: $sampleWav" -ForegroundColor Cyan
  $sttForm = New-MultipartFormData -FilePath $sampleWav -FieldName "audio" -ContentType "audio/wav"
  $sttHeaders = $headers.Clone()
  $sttHeaders["Content-Type"] = "multipart/form-data; boundary=$($sttForm.Boundary)"
  Invoke-WebRequest -Method POST -Uri "$base/api/stt/transcribe" -UseBasicParsing -Headers $sttHeaders -Body $sttForm.Body
} else {
  Write-Host "Skipping STT (sample.wav not found)" -ForegroundColor Yellow
}

# Document upload (uses sample.txt in this folder)
$sampleDoc = Join-Path $scriptDir "sample.txt"
if (Test-Path $sampleDoc) {
  Write-Host "Document upload..." -ForegroundColor Cyan
  $docForm = New-MultipartFormData -FilePath $sampleDoc -FieldName "document" -ContentType "text/plain"
  $docHeaders = $headers.Clone()
  $docHeaders["Content-Type"] = "multipart/form-data; boundary=$($docForm.Boundary)"
  $docResp = Invoke-WebRequest -Method POST -Uri "$base/api/documents/upload" -UseBasicParsing -Headers $docHeaders -Body $docForm.Body
  $docJson = $docResp.Content | ConvertFrom-Json
  $documentId = $docJson.document_id
  Write-Host "Uploaded document_id: $documentId" -ForegroundColor Green

  # Quiz generation
  Write-Host "Quiz generation..." -ForegroundColor Cyan
  $quizBody = @{ document_id = $documentId; num_questions = 3 } | ConvertTo-Json
  $quizResp = Invoke-WebRequest -Method POST -Uri "$base/api/quiz/generate" -UseBasicParsing -ContentType "application/json" -Headers $headers -Body $quizBody
  $quizJson = $quizResp.Content | ConvertFrom-Json
  Write-Host "Generated quiz_id: $($quizJson.quiz_id)" -ForegroundColor Green
} else {
  Write-Host "Skipping document/quiz (sample.txt not found)" -ForegroundColor Yellow
}

Write-Host "Done. Services remain running. To stop: docker compose down" -ForegroundColor Green
