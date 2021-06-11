# Create Bastion Host Security Group

resource "aws_security_group" "carsales_bastion_sg" {
  vpc_id = aws_vpc.carsales_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name        = "CarSales Bastion Security Group"
    Terraform   = "true"
    } 
}


# CREATE BASTION HOST IN PUBLIC SUBNET

resource "aws_instance" "carsales_bastion_host-1a" {
  ami = "ami-02a2e419a7ed55325"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.carsales_bastion_sg.id]
  subnet_id = aws_subnet.carsales-public-1a.id
  tags = {
    Name = "CarSales Bastion Host - 1A"
    Terraform = true
  }
}

# CREATE BASTION HOST IN  PUBLIC SUBNET

resource "aws_instance" "carsales_bastion_host-1b" {
  ami = "ami-02a2e419a7ed55325"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.carsales_bastion_sg.id]
  subnet_id = aws_subnet.carsales-public-1b.id
  tags = {
    Name = "CarSales Bastion Host - 1B"
    Terraform = true
  }
}
