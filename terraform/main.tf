# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "project-2-vpc"
    Environment = "dev"
    Project     = "aws-devops"
  }
}

# ============================================================
# Public Subnet 1
# ============================================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "project-2-public-subnet"
  }
}

# ============================================================
# Public Subnet 2
# ============================================================

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "project-2-public-subnet-2"
    Project = "aws-devops"
  }
}

# ============================================================
# Private Subnet 1
# ============================================================

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "project-2-private-subnet"
  }
}

# ============================================================
# Private Subnet 2
# ============================================================

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name    = "project-2-private-subnet-2"
    Project = "aws-devops"
  }
}

# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "project-2-igw"
  }
}

# ============================================================
# Public Route Table
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "project-2-public-rt"
  }
}

# ============================================================
# Public Route Table Associations
# ============================================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# IAM Role for EC2 + SSM
# ============================================================

resource "aws_iam_role" "ec2_ssm_role" {
  name = "project-2-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "project-2-ec2-ssm-role"
    Project = "aws-devops"
  }
}

# ============================================================
# Attach SSM Policy
# ============================================================

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# EC2 Instance Profile
# ============================================================

resource "aws_iam_instance_profile" "ec2" {
  name = "project-2-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ============================================================
# ALB Security Group
# ============================================================

resource "aws_security_group" "alb" {
  name        = "project-2-alb-sg"
  description = "Allow HTTP traffic to the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "project-2-alb-sg"
    Project = "aws-devops"
  }
}

# ============================================================
# EC2 Security Group
# ============================================================

resource "aws_security_group" "ec2" {
  name        = "project-2-ec2-sg"
  description = "Security group for project 2 EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP only from ALB
  ingress {
    description     = "HTTP from Application Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "project-2-ec2-sg"
    Project = "aws-devops"
  }
}

# ============================================================
# EC2 Instance
# ============================================================

resource "aws_instance" "app" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name        = "project-2-app-server"
    Environment = "dev"
    Project     = "aws-devops"
  }
}

# ============================================================
# S3 Bucket for Ansible SSM
# ============================================================

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "ansible_ssm" {
  bucket = "project-2-ansible-ssm-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "project-2-ansible-ssm"
    Project = "aws-devops"
  }
}

# ============================================================
# S3 Public Access Block
# ============================================================

resource "aws_s3_bucket_public_access_block" "ansible_ssm" {
  bucket = aws_s3_bucket.ansible_ssm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================
# S3 Server-Side Encryption
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_ssm" {
  bucket = aws_s3_bucket.ansible_ssm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================
# S3 Access for SSM Operations
# ============================================================

resource "aws_iam_policy" "ansible_ssm_s3" {
  name        = "project-2-ansible-ssm-s3"
  description = "Allow EC2 to access the Ansible SSM transfer bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetEncryptionConfiguration"
        ]

        Resource = "${aws_s3_bucket.ansible_ssm.arn}/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation"
        ]

        Resource = aws_s3_bucket.ansible_ssm.arn
      }
    ]
  })
}

# ============================================================
# Attach S3 Policy to EC2 Role
# ============================================================

resource "aws_iam_role_policy_attachment" "ansible_ssm_s3" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ansible_ssm_s3.arn
}

# ============================================================
# Application Load Balancer
# ============================================================

resource "aws_lb" "app" {
  name               = "project-2-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name    = "project-2-alb"
    Project = "aws-devops"
  }
}

# ============================================================
# ALB Target Group
# ============================================================

resource "aws_lb_target_group" "app" {
  name     = "project-2-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name    = "project-2-app-tg"
    Project = "aws-devops"
  }
}

# ============================================================
# Register EC2 with Target Group
# ============================================================

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 80
}

# ============================================================
# ALB HTTP Listener
# ============================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ============================================================
# RDS DB Subnet Group
# ============================================================

resource "aws_db_subnet_group" "mysql" {
  name = "project-2-rds-subnet-group"

  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name    = "project-2-rds-subnet-group"
    Project = "aws-devops"
  }
}

# ============================================================
# RDS Security Group
# ============================================================

resource "aws_security_group" "rds" {
  name        = "project-2-rds-sg"
  description = "Allow MySQL traffic from the EC2 application server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "project-2-rds-sg"
    Project = "aws-devops"
  }
}

# ============================================================
# RDS MySQL
# ============================================================

resource "aws_db_instance" "mysql" {
  identifier = "project-2-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"

  db_name  = "project2db"
  username = "admin"
  password = var.db_password

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.mysql.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  tags = {
    Name    = "project-2-mysql"
    Project = "aws-devops"
  }
}
