
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.demo_aws_vpc.id
  name = "demo-rds-sg"
  description = "Allow SSH, Http and Https"
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "postgresql"
    cidr_blocks = ["${aws_security_group.ec2_sg.id}"]
  }
  
}

resource "aws_rds_cluster" "postgres_cluster" {
  count             			= length(var.public_subnet_cidrs)
  cluster_identifier      = "postgres-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version 		  		= "14.4"
  availability_zones      = element(data.aws_availability_zones.available.names, count.index)
  database_name           = "demo_db"
  master_username         = "root"
  master_password         = var.database_master_password

	serverlessv2_scaling_configuration {
		max_capacity = 4
		min_capacity = 1
	}
}