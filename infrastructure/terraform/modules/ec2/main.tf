# Launch Template for Container Hosts
resource "aws_launch_template" "container_host" {
  name_prefix   = "${var.project_name}-container-host-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.security_groups.containers_sg_id,
    var.security_groups.ssh_sg_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user-data/container-host.sh", {
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-container-host-${var.environment}"
      Environment = var.environment
      Type        = "ContainerHost"
    }
  }
}

# Auto Scaling Group for Container Hosts
resource "aws_autoscaling_group" "container_hosts" {
  name                = "${var.project_name}-container-hosts-${var.environment}"
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = []
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.container_host.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-container-host-${var.environment}"
    propagate_at_launch = true
  }
}

# Launch Template for Kafka Brokers
resource "aws_launch_template" "kafka_broker" {
  name_prefix   = "${var.project_name}-kafka-broker-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.kafka_instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.security_groups.kafka_sg_id,
    var.security_groups.ssh_sg_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = false
    }
  }

  user_data = base64encode(templatefile("${path.module}/user-data/kafka-broker.sh", {
    broker_id  = 1
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-kafka-broker-${var.environment}"
      Environment = var.environment
      Type        = "KafkaBroker"
    }
  }
}

# EC2 Instances for Kafka Brokers (3 instances)
resource "aws_instance" "kafka_brokers" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.kafka_instance_type
  key_name               = var.key_name
  subnet_id              = var.kafka_subnets[count.index % length(var.kafka_subnets)]
  vpc_security_group_ids = [
    var.security_groups.kafka_sg_id,
    var.security_groups.ssh_sg_id
  ]

  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user-data/kafka-broker.sh", {
    broker_id   = count.index + 1
    environment = var.environment
  }))

  tags = {
    Name        = "${var.project_name}-kafka-broker-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = "KafkaBroker"
    BrokerId    = count.index + 1
  }
}

# EC2 Instances for Zookeeper (3 instances)
resource "aws_instance" "zookeeper" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.kafka_subnets[count.index % length(var.kafka_subnets)]
  vpc_security_group_ids = [
    var.security_groups.kafka_sg_id,
    var.security_groups.ssh_sg_id
  ]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user-data/zookeeper.sh", {
    zookeeper_id = count.index + 1
    environment  = var.environment
  }))

  tags = {
    Name        = "${var.project_name}-zookeeper-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Type        = "Zookeeper"
    ZookeeperId = count.index + 1
  }
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# CloudWatch monitoring
resource "aws_cloudwatch_metric_alarm" "container_host_cpu" {
  alarm_name          = "${var.project_name}-container-host-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors container host cpu utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.container_hosts.name
  }
}

# Outputs
output "container_host_asg_id" {
  value = aws_autoscaling_group.container_hosts.id
}

output "kafka_broker_ids" {
  value = aws_instance.kafka_brokers[*].id
}

output "zookeeper_ids" {
  value = aws_instance.zookeeper[*].id
}

