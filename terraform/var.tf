variable "aws_region" {
  description = "Region in which AWS Resources are made"
  type = string
  default = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "instance_keypair" {
  description = "RSA key for SSH"
  type = string
  default = "devops-project"          
}

variable "ami-id" {
  description = "AMI ID for EC-2 Instance"
  type = string
  default = "ami-0f5ee92e2d63afc18"
}