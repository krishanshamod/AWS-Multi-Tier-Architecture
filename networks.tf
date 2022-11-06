resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "frontend" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "frontend"
  }
}

resource "aws_subnet" "backend" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.64.0/18"

  tags = {
    Name = "backend"
  }
}

resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/18"

  tags = {
    Name = "database"
  }
}


