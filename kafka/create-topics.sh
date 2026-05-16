#!/bin/bash

# Kafka topics creation script
# Run this after Kafka cluster is up

KAFKA_BOOTSTRAP_SERVERS="localhost:9092"

# Create topics with replication factor 2 and partitions
topics=(
  "document.uploaded:3:2"
  "document.processed:3:2"
  "notes.generated:3:2"
  "quiz.requested:3:2"
  "quiz.generated:3:2"
  "audio.transcription.requested:3:2"
  "audio.transcription.completed:3:2"
  "audio.generation.requested:3:2"
  "audio.generation.completed:3:2"
  "chat.message:3:2"
)

for topic_config in "${topics[@]}"; do
  IFS=':' read -r topic partitions replication <<< "$topic_config"
  
  echo "Creating topic: $topic with $partitions partitions and replication factor $replication"
  
  docker exec -it kafka-1 kafka-topics --create \
    --bootstrap-server localhost:9092 \
    --topic "$topic" \
    --partitions "$partitions" \
    --replication-factor "$replication" \
    --if-not-exists
done

echo "All topics created successfully!"

