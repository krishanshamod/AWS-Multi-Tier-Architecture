// Generates a private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Create the key pair
resource "aws_key_pair" "bastion-key-pair" {
  key_name   = "bastion-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

// Save file private key
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.bastion-key-pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

// Get latest Ubuntu Linux Focal Fossa 20.04 AMI
data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instance
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.ubuntu-linux-2004.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.frontend.id
  availability_zone           = "ap-south-1a"
  vpc_security_group_ids      = [aws_security_group.bastion-vm-sg.id]
  source_dest_check           = false
  key_name                    = aws_key_pair.bastion-key-pair.key_name
  associate_public_ip_address = true

  user_data = file("bastion_config.sh")

  # root disk
  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 10
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "bastion_host"
  }
}

// Elastic IP for bastion host
resource "aws_eip" "bastion_host_eip" {
  instance = aws_instance.bastion_host.id
  vpc      = true

  tags = {
    Name = "bastion_host_eip"
  }
}