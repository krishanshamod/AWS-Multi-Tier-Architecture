# Define the security group for the bastion host
resource "aws_security_group" "bastion-vm-sg" {
  name        = "bastion-vm-sg"
  description = "Allow incoming connections"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  tags = {
    Name = "bastion-vm-sg"
  }
}