// virtual private cloud
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

// subnet for frontend resources
resource "aws_subnet" "frontend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "frontend"
  }
}

// subnet for backend resources
resource "aws_subnet" "backend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "backend"
  }
}

// subnet for database resources
resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/18"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "database"
  }
}

// internet gateway for the VPC
resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_internet_gateway"
  }
}

// route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }

  tags = {
    Name = "public_route_table"
  }
}

// route table association for the frontend subnet
resource "aws_route_table_association" "frontend_subnet_association" {
  subnet_id      = aws_subnet.frontend.id
  route_table_id = aws_route_table.public_route_table.id
}

// elastic ip for the nat gateway
resource "aws_eip" "main_nat_gateway_eip" {
  vpc = true

  tags = {
    Name = "main_nat_gateway_eip"
  }
}

// nat gateway for the private subnets
resource "aws_nat_gateway" "main_nat_gateway" {
  allocation_id = aws_eip.main_nat_gateway_eip.id
  subnet_id     = aws_subnet.frontend.id

  tags = {
    Name = "main_nat_gateway"
  }

  depends_on = [aws_internet_gateway.main_internet_gateway]
}

// route table for the private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_nat_gateway.id
  }

  tags = {
    Name = "private_route_table"
  }
}

// route table association for the backend subnet
resource "aws_route_table_association" "backend_subnet_association" {
  subnet_id      = aws_subnet.backend.id
  route_table_id = aws_route_table.private_route_table.id
}

// route table association for the database subnet
resource "aws_route_table_association" "database_subnet_association" {
  subnet_id      = aws_subnet.database.id
  route_table_id = aws_route_table.private_route_table.id
}



