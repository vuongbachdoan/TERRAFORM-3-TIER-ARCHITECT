variable "vpc_id" {
  description = "VPC ID pass from root main.tf"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "List of IDs for private subnets"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "List of IDs for public subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "ami_id" {
  type = string
  description = "AMI id value"
  default = "ami-0eb4694aa6f249c52"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "min_size" {
  type = number
  default = 1
  description = "Minimum number of instances in the ASG"
}

variable "max_size" {
  type = number
  default = 2
  description = "Maximum number of instances in the ASG"
}

variable "desired_capacity" {
  type = number
  default = 1
  description = "Desired number of instances in the ASG"
}