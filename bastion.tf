# Generates a private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the key pair
resource "aws_key_pair" "key_pair" {
  key_name   = "bastion-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file private key
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}