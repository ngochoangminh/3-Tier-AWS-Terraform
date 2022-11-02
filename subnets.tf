# public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.1.0/24"
  availability_zone = "a"
  tags = {
    "Name" = "demo public subnet 1"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.3.0/24"
  availability_zone = "b"
  tags = {
    "Name" = "demo public subnet 2"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# Map public subnets to the public route table
resource "aws_route_table_association" "tr_public_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_route_table.public_route_table
  ]
}

resource "aws_route_table_association" "rt_public_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_route_table.public_route_table
  ]
}

# Private subnet
resource "aws_subnet" "application_1" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.64.0/24"
  availability_zone = "a"
  tags = {
    "Name" = "demo applicant 1"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

resource "aws_subnet" "application_2" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.128.0/24"
  availability_zone = "a"
  tags = {
    "Name" = "demo applicant 2"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# define NAT, allow access from inside app subnet to the Internet
resource "aws_eip" "nat_1" {
  vpc = true
}

resource "aws_eip" "nat_2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id = aws_subnet.application_1.id
  tags = {
    "Name" = "demo NAT 1"
  }
  depends_on = [
    aws_internet_gateway.demoigw
  ]
}
resource "aws_nat_gateway" "nay_2" {
  allocation_id = aws_eip.nat_2
  subnet_id = aws_subnet.application_2.id
  tags = {
    "Name" = "demo NAT 2"
  }
  depends_on =[
    aws_internet_gateway.demoigw
  ]
}

# add route table for each applicant subnet
resource "aws_route_table" "application_route_table_1" {
  vpc_id = aws_vpc.demovpc.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  } ]
  tags = {
    "Name" = "demo rt application 1"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}
resource "aws_route_table" "application_route_table_2" {
  vpc_id = aws_vpc.demovpc.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  } ]
  tags = {
    "Name" = "demo rt application 2"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# Connect applicantion sub net to the nat gateway
resource "aws_route_table_association" "rt_application_1" {
  subnet_id = aws_subnet.application_1.id
  route_table_id = aws_route_table.application_route_table_1.id

  depends_on = [
    aws_nat_gateway.nat_1
  ]
}
resource "aws_route_table_association" "rt_application_2" {
  subnet_id = aws_subnet.application_2.id
  route_table_id = aws_route_table.application_route_table_2.id

  depends_on = [
    aws_nat_gateway.nat_2
  ]
}

# Data private subnet. Don't allow any connection with the internet
resource "aws_subnet" "data_1" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.200.0/24"
  availability_zone = "a"
  tags = {
    "Name" = "demo data 1"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}
resource "aws_subnet" "data_2" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block = "10.110.201.0/24"
  availability_zone = "b"
  tags = {
    "Name" = "demo data 2"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# add route table for each data subnet
resource "aws_route_table" "data_route_table_1"{
  vpc_id = aws_vpc.demovpc
  route = [{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }]
  tags = {
    "Name" = "demo rt data 1"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}
resource "aws_route_table" "data_route_table_2"{
  vpc_id = aws_vpc.demovpc
  route = [{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }]
  tags = {
    "Name" = "demo rt data 2"
  }
  depends_on = [
    aws_vpc.demovpc
  ]
}

# connect data subnet to nat gateway
resource "aws_route_table_association" "rt_data_1" {
  subnet_id = aws_subnet.data_1.id
  route_table_id = aws_route_table.data_route_table_1.id

  depends_on = [
    aws_nat_gateway.nat_1
  ]
}
resource "aws_route_table_association" "rt_data_2" {
  subnet_id = aws_subnet.data_2.id
  route_table_id = aws_route_table.data_route_table_2.id

  depends_on = [
    aws_nat_gateway.nat_2
  ]
}