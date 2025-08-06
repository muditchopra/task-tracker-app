data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "task_tracker_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "task_tracker_igw" {
  vpc_id = aws_vpc.task_tracker_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnet
resource "aws_subnet" "task_tracker_public_subnet" {
  vpc_id                  = aws_vpc.task_tracker_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table
resource "aws_route_table" "task_tracker_public_rt" {
  vpc_id = aws_vpc.task_tracker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task_tracker_igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Association
resource "aws_route_table_association" "task_tracker_public_rta" {
  subnet_id      = aws_subnet.task_tracker_public_subnet.id
  route_table_id = aws_route_table.task_tracker_public_rt.id
}
