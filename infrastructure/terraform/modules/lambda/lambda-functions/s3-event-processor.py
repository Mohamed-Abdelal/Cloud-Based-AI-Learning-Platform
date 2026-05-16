import json
import boto3
import os

def handler(event, context):
    """
    Lambda function to process S3 events and publish to Kafka
    """
    s3 = boto3.client('s3')
    
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        event_name = record['eventName']
        
        # Determine service based on bucket name
        if 'document-reader' in bucket_name:
            topic = 'document.uploaded'
        elif 'stt-service' in bucket_name:
            topic = 'audio.transcription.requested'
        else:
            continue
        
        # Publish to Kafka (would need kafka-python library)
        # This is a placeholder - actual implementation would use Kafka producer
        print(f"Would publish to topic {topic}: bucket={bucket_name}, key={object_key}, event={event_name}")
        
        # In production, use kafka-python:
        # from kafka import KafkaProducer
        # producer = KafkaProducer(bootstrap_servers=os.environ['KAFKA_BOOTSTRAP_SERVERS'])
        # producer.send(topic, value=json.dumps({
        #     'bucket': bucket_name,
        #     'key': object_key,
        #     'event': event_name
        # }).encode('utf-8'))
    
    return {
        'statusCode': 200,
        'body': json.dumps('S3 events processed successfully')
    }

