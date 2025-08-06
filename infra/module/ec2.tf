#
# ---------------EC2 Resources---------------
#  * Ubuntu AMI
#  * EC2 Security Group 
#  * IAM Role
#  * Key Pair
#  * EC2 Instance

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-lts-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "task_tracker_sg" {
  name        = "${var.project_name}-security-group"
  description = "Security group for Task Tracker API"
  vpc_id      = aws_vpc.task_tracker_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "FastAPI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role 
resource "aws_iam_role" "ec2-role" {
  name = "${var.project_name}-instance-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": ["sts:AssumeRole"]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ec2-AmazonS3ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = "${aws_iam_role.ec2-role.name}"
}

resource "aws_iam_role_policy_attachment" "ec2-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = "${aws_iam_role.ec2-role.name}"
}

resource "aws_iam_instance_profile" "EC2-task-tracker-profile" {
  name = "task-tracker-profile"
  role = aws_iam_role.ec2-role.name
}

# Key Pair
resource "aws_key_pair" "task_tracker_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

# EC2 Instance
resource "aws_instance" "task_tracker_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.task_tracker_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.EC2-task-tracker-profile.name
  vpc_security_group_ids = [aws_security_group.task_tracker_sg.id]
  subnet_id              = aws_subnet.task_tracker_public_subnet.id

  # User data script for initial setup
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_compose_version = "2.24.0"
  }))

  # Root block device
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    Project     = var.project_name
  }
}