#!/bin/bash
set -e

zookeeper_id=${zookeeper_id}
environment=${environment}

yum update -y

# Install Java
yum install -y java-11-amazon-corretto

# Install Zookeeper
cd /opt
wget https://downloads.apache.org/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz
tar -xzf apache-zookeeper-3.9.1-bin.tar.gz
mv apache-zookeeper-3.9.1-bin zookeeper
chown -R ec2-user:ec2-user /opt/zookeeper

# Create Zookeeper data directory on EBS volume
mkdir -p /data/zookeeper
chown -R ec2-user:ec2-user /data/zookeeper

# Configure Zookeeper
cat > /opt/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
dataDir=/data/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=zookeeper-1:2888:3888
server.2=zookeeper-2:2888:3888
server.3=zookeeper-3:2888:3888
EOF

# Create myid file
echo ${zookeeper_id} > /data/zookeeper/myid

# Create systemd service for Zookeeper
cat > /etc/systemd/system/zookeeper.service <<EOF
[Unit]
Description=Apache Zookeeper Server
After=network.target

[Service]
Type=simple
User=ec2-user
Environment="JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto"
ExecStart=/opt/zookeeper/bin/zkServer.sh start-foreground
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Zookeeper ${zookeeper_id} setup completed at $(date)" >> /var/log/user-data.log

