
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.demo_aws_vpc.id
  name = "demo-ec2-sg"
  description = "Allow SSH, Http and Https"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "rappid_dev" {
  ami = data.aws_ami.ubuntu.id // Amazone Machine Images
  instance_type = "t3a.medium"
  vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
  subnet_id = aws_subnet.private_backend_subnets.id 
  tags = {
    Name = var.test_var
  }
}

resource "aws_eip" "rappid_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "rappid_eip_assoc" {
  instance_id   = aws_instance.rappid_dev.id
  allocation_id = aws_eip.rappid_eip.id
}