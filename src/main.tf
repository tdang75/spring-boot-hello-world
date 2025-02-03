provider "aws" {
  region = "us-east-1"  # Adjust the region as needed
  shared_credentials_files = ["./credentials.txt"]
  profile                 = "simplilearn"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"  # Change as needed
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"  # Change as needed
  tags = {
    Name = "private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"  # Change as needed
  tags = {
    Name = "private-subnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "ec2_security_group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access (replace with your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "rds_security_group"

  ingress {
    from_port   = 3306  # Adjust for your database (e.g., 3306 for MySQL)
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  # Allow EC2 access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allocate Elastic IP
resource "aws_eip" "my_eip" {
  vpc = true  # Set to true if the EC2 instance is in a VPC
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.my_eip.id
}

resource "aws_key_pair" "key_pair1" {
  key_name   = "Key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP48o/HXJm+VniNE6gKraeJBI63TKMJlSUAoJqsIjsd1aSlTwffdXN6HagnOJkZfkIUpmMVJezmc/SShg++PqotVhbHzKUq41JOsch1k4EmUMhKiK9wDQZKJ6tJkkw3OzTdp7c3TChnuBbNr1BHFbCfLHauIpwZKbfYLOIu0GMoUjz4toxd1gEf08GCKHSeUJPSER0cfV09H3gh26zEY3/RwpX7TJ6j53OyK0xqh9hC9tpuT9bsUQzCdcKiCAQ2UYwt1EsPN/J7xUao3j5SeCwE1wAj87j5N/TIUDsLeq/F+Av6xvnuzXZO8Zcmgt3BPTCqcxO1tsiTyqWOT1ehMltSynCrhs74J2Hsm+qS37VjJ3dtEROzWOG83Th7NXvzH4cm60h6o74+LmzIw0Zi5+7FpPCFdfhJqR2nnl/dtJr7PCnB6qZMRGcg5Frdw08vSo1Uz50w0JXHPUxIsX/NYpVNZ6HrbSzud5k+HVE9gSZ6YcacV4M3Q2hjIor8F2VCnM="
}

resource "aws_instance" "web_server" {
  ami           = "ami-0fff1b9a61dec8a5f"  # Amazon Linux 2023 AMI 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]
  key_name = aws_key_pair.key_pair1.key_name
  tags = {
    Name = "WebServer"
  }
}

resource "aws_db_instance" "my_db" {
  identifier              = "mydatabase"
  engine                 = "mysql"  # Change based on your needs
  instance_class         = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  username               = "admin"
  password               = "password--123"  # Use secrets manager for production
  db_name                = "mydb"
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tags = {
    Name = "My DB subnet group"
  }
}

output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.my_db.endpoint
}

