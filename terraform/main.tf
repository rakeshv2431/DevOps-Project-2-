resource "aws_instance" "test-server" {
  ami = data.aws_ami.ami-id.id
  instance_type = var.instance_type
  key_name = var.instance_keypair
  subnet_id = aws_subnet.devops-public-subnet-1.id 
   vpc_security_group_ids = [
    aws_security_group.vpc-ssh.id,
    aws_security_group.vpc-web.id
  ]
  for_each = toset(["Jenkins-master", "Jenkins-slave", "Ansible"])
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    "Name" = "DevOps-VPC"
  }
}

resource "aws_subnet" "devops-public-subnet-1" {
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    "Name" = "DevOps-public-subnet-1"
  }
}

resource "aws_subnet" "devops-public-subnet-2" {
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"
  tags = {
    "Name" = "DevOps-public-subnet-2"
  }

}
resource "aws_internet_gateway" "devops-igw" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = {
    "Name" = "devops-igw"
  } 
}

resource "aws_route_table" "devops-public-rt" {
  vpc_id = aws_vpc.devops-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-igw.id
  }
  tags = {
    "Name" = "DevOps-public-RT"
  }
}

resource "aws_route_table_association" "devops-rta-public-subnet-1" {
  subnet_id = aws_subnet.devops-public-subnet-1.id
  route_table_id = aws_route_table.devops-public-rt.id
}

resource "aws_route_table_association" "devops-rta-public-subnet-2" {
  subnet_id = aws_subnet.devops-public-subnet-2.id
  route_table_id = aws_route_table.devops-public-rt.id
}

resource "aws_security_group" "vpc-ssh" {
  name = "vpc-ssh"
  vpc_id = aws_vpc.devops-vpc.id
  description = "Dev VPC SSH"

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "vpc-ssh"
  }
}

resource "aws_security_group" "vpc-web" {
  name = "vpc-web"
  description = "Dev VPC web"
  vpc_id = aws_vpc.devops-vpc.id

  ingress {
    description = "Allow port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 443"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins GUI access"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "vpc-web"
  }
}