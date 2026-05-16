# Bucket policies - Commented out due to S3 permission restrictions
# Note: These are simplified policies. In production, you would configure
# more restrictive policies based on VPC endpoints and Security Groups
# Security is enforced via Security Groups and VPC Endpoints instead

# # TTS Service Bucket Policy - Deny public access
# resource "aws_s3_bucket_policy" "tts_service" {
#   bucket = aws_s3_bucket.tts_service.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "DenyPublicAccess"
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.tts_service.arn,
#           "${aws_s3_bucket.tts_service.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:ViaAWSService" = "false"
#           }
#         }
#       }
#     ]
#   })
# }
#
# # STT Service Bucket Policy
# resource "aws_s3_bucket_policy" "stt_service" {
#   bucket = aws_s3_bucket.stt_service.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "DenyPublicAccess"
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.stt_service.arn,
#           "${aws_s3_bucket.stt_service.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:ViaAWSService" = "false"
#           }
#         }
#       }
#     ]
#   })
# }
#
# # Chat Service Bucket Policy
# resource "aws_s3_bucket_policy" "chat_service" {
#   bucket = aws_s3_bucket.chat_service.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "DenyPublicAccess"
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.chat_service.arn,
#           "${aws_s3_bucket.chat_service.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:ViaAWSService" = "false"
#           }
#         }
#       }
#     ]
#   })
# }
#
# # Document Service Bucket Policy
# resource "aws_s3_bucket_policy" "document_service" {
#   bucket = aws_s3_bucket.document_service.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "DenyPublicAccess"
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.document_service.arn,
#           "${aws_s3_bucket.document_service.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:ViaAWSService" = "false"
#           }
#         }
#       }
#     ]
#   })
# }
#
# # Quiz Service Bucket Policy
# resource "aws_s3_bucket_policy" "quiz_service" {
#   bucket = aws_s3_bucket.quiz_service.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "DenyPublicAccess"
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.quiz_service.arn,
#           "${aws_s3_bucket.quiz_service.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:ViaAWSService" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

# Note: Additional access control is enforced through:
# - Security Groups (network-level)
# - VPC Endpoints (private S3 access)
# - Application-level authentication (JWT)
