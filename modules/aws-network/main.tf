# =============================================================================
# AWS Network Module - Main
# =============================================================================
# Creates the foundational AWS networking infrastructure:
#   - VPC with DNS support
#   - Public subnets across dynamically fetched AZs (no hardcoding)
#   - Internet gateway for public access
#   - Route table with internet route
#   - Security group allowing PostgreSQL (port 5432) access
#
# ⚠️ SECURITY NOTE: The security group allows 0.0.0.0/0 on port 5432 for
# demo purposes ONLY. In production, restrict this to specific CIDR ranges
# (e.g., your office IP or DMS replication instance IP).
# =============================================================================

# -----------------------------------------------------------------------------
# Dynamic Availability Zones — no hardcoding of region-specific AZ names
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Public Subnet
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-${data.aws_availability_zones.available.names[0]}"
    Project = var.project_name
  }
}

# Create a second subnet in a different AZ (required by RDS subnet group)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-${data.aws_availability_zones.available.names[1]}"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Route Table
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route all traffic to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# DB Subnet Group (RDS requires subnets in at least 2 AZs)
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.public_b.id]

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Security Group for PostgreSQL
# -----------------------------------------------------------------------------
resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-postgres-sg"
  description = "Allow PostgreSQL inbound traffic (port 5432)"
  vpc_id      = aws_vpc.main.id

  # ⚠️ DEMO ONLY: Allow PostgreSQL from anywhere
  # In production, restrict to specific CIDRs
  ingress {
    description = "PostgreSQL from anywhere (DEMO ONLY)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-postgres-sg"
    Project = var.project_name
  }
}
