
provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "demo_aws_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Demo AWS VPC"
  }
}

# Create Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.demo_aws_vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_backend_subnets" {
  count             = length(var.private_backend_subnet_cidrs) # count=2
  vpc_id            = aws_vpc.demo_aws_vpc.id
  cidr_block        = element(var.private_backend_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available, count.index)

  tags = {
    Name = "Private backend subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_data_subnets" {
  count             = length(var.private_data_subnet_cidrs) # count=2
  vpc_id            = aws_vpc.demo_aws_vpc.id
  cidr_block        = element(var.private_data_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available, count.index)

  tags = {
    Name = "Private data subnet ${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_aws_vpc.id

  tags = {
    Name = "Demo AWS VPC Internet Gateway"
  }
}


# attach internet gateway with public subnet
resource "aws_route_table" "demo_public_rt" {
  vpc_id = aws_vpc.demo_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "Demo public route table"
  }
}

resource "aws_route_table_association" "demo_public_rt_asso" {
  count          = count(var.aws_availability_zones)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.demo_public_rt.id

}


# Create Elastic IP for internet gateway
resource "aws_eip" "demo_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.demo_igw"]
}

# Create Nat Gateway
resource "aws_nat_gateway" "demo_nat_gw" {
  allocation_id = aws_eip.demo_eip.id
  subnet_id     = aws_subnet.public_subnets.id
  depends_on    = ["aws_internet_gateway.demo_igw"]
}


# for private backend
resource "aws_route_table" "private_backend_rt" {
  vpc_id = aws_vpc.demo_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "Demo private route table"
  }
}

resource "aws_route_table_association" "private_backend_rt_asso" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.private_backend_subnets.id
  route_table_id = aws_route_table.private_backend_rt.id

}


# for private data
resource "aws_route_table" "private_data_rt" {
  vpc_id = aws_vpc.demo_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "Demo private route table"
  }
}

resource "aws_route_table_association" "private_data_rt_asso" {
  count          = length(var.aws_availability_zones)
  subnet_id      = element(aws_subnet.private_data_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_data_rt.id

}

