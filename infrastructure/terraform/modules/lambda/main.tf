# Lambda functions - Commented out due to IAM access restrictions
# All Lambda resources require IAM roles which cannot be created with current account permissions
# See IAM Design Document for theoretical implementation

# # Lambda function for S3 event processing
# resource "aws_lambda_function" "s3_event_processor" {
#   filename      = "${path.module}/lambda-functions/s3-event-processor.zip"
#   function_name = "${var.project_name}-s3-event-processor-${var.environment}"
#   role          = aws_iam_role.lambda.arn
#   handler       = "index.handler"
#   runtime       = "python3.11"
#   timeout       = 60
#   memory_size   = 256
#
#   vpc_config {
#     subnet_ids         = var.private_subnets
#     security_group_ids = [var.security_groups.lambda_sg_id]
#   }
#
#   environment {
#     variables = {
#       ENVIRONMENT = var.environment
#       KAFKA_BOOTSTRAP_SERVERS = "kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092"
#     }
#   }
#
#   tags = {
#     Name        = "${var.project_name}-s3-event-processor-${var.environment}"
#     Environment = var.environment
#   }
# }
#
# # IAM Role for Lambda
# resource "aws_iam_role" "lambda" {
#   name = "${var.project_name}-lambda-role-${var.environment}"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = {
#     Name = "${var.project_name}-lambda-role-${var.environment}"
#   }
# }
#
# # Lambda function for cleanup tasks
# resource "aws_lambda_function" "cleanup" {
#   filename      = "${path.module}/lambda-functions/cleanup.zip"
#   function_name = "${var.project_name}-cleanup-${var.environment}"
#   role          = aws_iam_role.lambda.arn
#   handler       = "index.handler"
#   runtime       = "python3.11"
#   timeout       = 300
#   memory_size   = 512
#
#   vpc_config {
#     subnet_ids         = var.private_subnets
#     security_group_ids = [var.security_groups.lambda_sg_id]
#   }
#
#   environment {
#     variables = {
#       ENVIRONMENT = var.environment
#     }
#   }
#
#   tags = {
#     Name        = "${var.project_name}-cleanup-${var.environment}"
#     Environment = var.environment
#   }
# }
#
# # CloudWatch Events rule for scheduled cleanup
# resource "aws_cloudwatch_event_rule" "cleanup_schedule" {
#   name                = "${var.project_name}-cleanup-schedule-${var.environment}"
#   description         = "Trigger cleanup Lambda daily"
#   schedule_expression = "cron(0 2 * * ? *)" # Daily at 2 AM
# }
#
# resource "aws_cloudwatch_event_target" "cleanup_target" {
#   rule      = aws_cloudwatch_event_rule.cleanup_schedule.name
#   target_id = "CleanupLambdaTarget"
#   arn       = aws_lambda_function.cleanup.arn
# }
#
# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.cleanup.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.cleanup_schedule.arn
# }
#
# # Outputs
# output "lambda_functions" {
#   value = {
#     s3_event_processor = aws_lambda_function.s3_event_processor.arn
#     cleanup            = aws_lambda_function.cleanup.arn
#   }
# }

