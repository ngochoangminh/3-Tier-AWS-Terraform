
# Create VPC
resource "aws_vpc" "demovpc" {
  cird_block            = "10.0.0.0/16"
  instance_tenancy      ="default"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tag = {
    Name = "Demo VPC"
  }
}
# Define Internet Gateway
resource "aws_internet_gateway" "demoigw" {
  vpc_id = aws_vpc.demovpc.id
  tags = {
    "Name" = "Demo IGW"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# Define Route table for public access
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demovpc.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoigw.id
  } ]
  tags = {
    "Name" = "Demo RT Public"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# Define Route table for private access
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.demovpc.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoigw.id
  } ]
  tags = {
    "Name" = "Demo RT Private"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}