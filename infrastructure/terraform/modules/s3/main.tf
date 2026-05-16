# S3 Bucket for TTS Service
resource "aws_s3_bucket" "tts_service" {
  bucket = "${var.project_name}-tts-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-tts-service-storage-${var.environment}"
    Service     = "tts-service"
    Environment = var.environment
  }
}

# S3 advanced configurations commented out due to permission restrictions
# resource "aws_s3_bucket_versioning" "tts_service" {
#   bucket = aws_s3_bucket.tts_service.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "tts_service" {
#   bucket = aws_s3_bucket.tts_service.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "tts_service" {
#   bucket = aws_s3_bucket.tts_service.id
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# S3 Bucket for STT Service
resource "aws_s3_bucket" "stt_service" {
  bucket = "${var.project_name}-stt-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-stt-service-storage-${var.environment}"
    Service     = "stt-service"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "stt_service" {
  bucket = aws_s3_bucket.stt_service.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stt_service" {
  bucket = aws_s3_bucket.stt_service.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stt_service" {
  bucket = aws_s3_bucket.stt_service.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Chat Service
resource "aws_s3_bucket" "chat_service" {
  bucket = "${var.project_name}-chat-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-chat-service-storage-${var.environment}"
    Service     = "chat-service"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "chat_service" {
  bucket = aws_s3_bucket.chat_service.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "chat_service" {
  bucket = aws_s3_bucket.chat_service.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "chat_service" {
  bucket = aws_s3_bucket.chat_service.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Document Reader Service
resource "aws_s3_bucket" "document_service" {
  bucket = "${var.project_name}-document-reader-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-document-reader-storage-${var.environment}"
    Service     = "document-service"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "document_service" {
  bucket = aws_s3_bucket.document_service.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "document_service" {
  bucket = aws_s3_bucket.document_service.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "document_service" {
  bucket = aws_s3_bucket.document_service.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Quiz Service
resource "aws_s3_bucket" "quiz_service" {
  bucket = "${var.project_name}-quiz-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-quiz-service-storage-${var.environment}"
    Service     = "quiz-service"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "quiz_service" {
  bucket = aws_s3_bucket.quiz_service.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "quiz_service" {
  bucket = aws_s3_bucket.quiz_service.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "quiz_service" {
  bucket = aws_s3_bucket.quiz_service.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for Shared Assets
resource "aws_s3_bucket" "shared_assets" {
  bucket = "${var.project_name}-shared-assets-${var.environment}"

  tags = {
    Name        = "${var.project_name}-shared-assets-${var.environment}"
    Service     = "shared"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "shared_assets" {
  bucket = aws_s3_bucket.shared_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared_assets" {
  bucket = aws_s3_bucket.shared_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policies for cost optimization - Commented out due to permission restrictions
# resource "aws_s3_bucket_lifecycle_configuration" "tts_service" {
#   bucket = aws_s3_bucket.tts_service.id
#
#   rule {
#     id     = "delete_old_files"
#     status = "Enabled"
#
#     filter {
#       prefix = ""
#     }
#
#     expiration {
#       days = 90
#     }
#   }
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "stt_service" {
#   bucket = aws_s3_bucket.stt_service.id
#
#   rule {
#     id     = "delete_old_files"
#     status = "Enabled"
#
#     filter {
#       prefix = ""
#     }
#
#     expiration {
#       days = 30
#     }
#   }
# }

# Outputs
output "bucket_names" {
  value = {
    tts_service      = aws_s3_bucket.tts_service.id
    stt_service     = aws_s3_bucket.stt_service.id
    chat_service    = aws_s3_bucket.chat_service.id
    document_service = aws_s3_bucket.document_service.id
    quiz_service    = aws_s3_bucket.quiz_service.id
    shared_assets   = aws_s3_bucket.shared_assets.id
  }
}

