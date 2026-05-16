import json
import boto3
import os
from datetime import datetime, timedelta

def handler(event, context):
    """
    Lambda function for cleanup tasks (delete old files, archive data)
    """
    s3 = boto3.client('s3')
    environment = os.environ.get('ENVIRONMENT', 'dev')
    
    buckets = [
        f"cloud-learning-platform-tts-service-storage-{environment}",
        f"cloud-learning-platform-stt-service-storage-{environment}",
        f"cloud-learning-platform-chat-service-storage-{environment}",
        f"cloud-learning-platform-document-reader-storage-{environment}",
        f"cloud-learning-platform-quiz-service-storage-{environment}"
    ]
    
    deleted_count = 0
    cutoff_date = datetime.now() - timedelta(days=90)
    
    for bucket_name in buckets:
        try:
            # List objects in bucket
            response = s3.list_objects_v2(Bucket=bucket_name)
            
            if 'Contents' in response:
                for obj in response['Contents']:
                    # Check if object is older than cutoff date
                    if obj['LastModified'].replace(tzinfo=None) < cutoff_date:
                        s3.delete_object(Bucket=bucket_name, Key=obj['Key'])
                        deleted_count += 1
                        print(f"Deleted {obj['Key']} from {bucket_name}")
        except Exception as e:
            print(f"Error processing bucket {bucket_name}: {str(e)}")
            continue
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Cleanup completed',
            'deleted_count': deleted_count
        })
    }

