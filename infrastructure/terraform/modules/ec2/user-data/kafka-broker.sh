#!/bin/bash
set -e

broker_id=${broker_id}
environment=${environment}

yum update -y

# Install Java
yum install -y java-11-amazon-corretto

# Install Kafka
cd /opt
wget https://downloads.apache.org/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
mv kafka_2.13-3.6.0 kafka
chown -R ec2-user:ec2-user /opt/kafka

# Create Kafka data directory on EBS volume
mkdir -p /data/kafka-logs
chown -R ec2-user:ec2-user /data/kafka-logs

# Configure Kafka (basic configuration - should be customized)
cat > /opt/kafka/config/server.properties <<EOF
broker.id=${broker_id}
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):9092
log.dirs=/data/kafka-logs
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
EOF

# Create systemd service for Kafka
cat > /etc/systemd/system/kafka.service <<EOF
[Unit]
Description=Apache Kafka Server
After=network.target zookeeper.service

[Service]
Type=simple
User=ec2-user
Environment="JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto"
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Note: Zookeeper should be installed separately
# This is a basic setup - production should use external Zookeeper

echo "Kafka broker ${broker_id} setup completed at $(date)" >> /var/log/user-data.log

