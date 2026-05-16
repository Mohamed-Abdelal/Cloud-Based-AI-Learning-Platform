# Network ACL for Public Subnets
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  # Allow HTTP from internet
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow HTTPS from internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow ephemeral ports for return traffic
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags = {
    Name = "${var.project_name}-public-nacl-${var.environment}"
  }
}

# Network ACL for Private Subnets (Containers)
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  # Allow HTTP from public subnets (ALB)
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow HTTPS from public subnets (ALB)
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow Kafka from Kafka subnets
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 30)
    action     = "allow"
  }

  ingress {
    rule_no    = 121
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 31)
    action     = "allow"
  }

  # Allow PostgreSQL from private subnets only
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow ephemeral ports
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags = {
    Name = "${var.project_name}-private-nacl-${var.environment}"
  }
}

# Network ACL for Data Subnets (RDS)
resource "aws_network_acl" "data" {
  vpc_id = aws_vpc.main.id

  # Allow PostgreSQL only from private subnets
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
    action     = "allow"
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 11)
    action     = "allow"
  }

  # Deny all other inbound
  ingress {
    rule_no    = 200
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "deny"
  }

  # Allow outbound to private subnets only
  egress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
    action     = "allow"
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 11)
    action     = "allow"
  }

  tags = {
    Name = "${var.project_name}-data-nacl-${var.environment}"
  }
}

# Network ACL for Kafka Subnets
resource "aws_network_acl" "kafka" {
  vpc_id = aws_vpc.main.id

  # Allow Kafka from private subnets
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
    action     = "allow"
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 11)
    action     = "allow"
  }

  # Allow Kafka inter-broker communication
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 30)
    action     = "allow"
  }

  ingress {
    rule_no    = 121
    protocol   = "tcp"
    from_port  = 9092
    to_port    = 9092
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 31)
    action     = "allow"
  }

  # Allow Zookeeper
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    from_port  = 2181
    to_port    = 2181
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow Zookeeper inter-node communication
  ingress {
    rule_no    = 140
    protocol   = "tcp"
    from_port  = 2888
    to_port    = 2888
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  ingress {
    rule_no    = 150
    protocol   = "tcp"
    from_port  = 3888
    to_port    = 3888
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow SSH from private subnets only
  ingress {
    rule_no    = 160
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow ephemeral ports
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags = {
    Name = "${var.project_name}-kafka-nacl-${var.environment}"
  }
}

# Associate NACLs with subnets
resource "aws_network_acl_association" "public" {
  count          = 2
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_network_acl_association" "private" {
  count          = 2
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_network_acl_association" "data" {
  count          = 2
  network_acl_id = aws_network_acl.data.id
  subnet_id      = aws_subnet.data[count.index].id
}

resource "aws_network_acl_association" "kafka" {
  count          = 2
  network_acl_id = aws_network_acl.kafka.id
  subnet_id      = aws_subnet.kafka[count.index].id
}

