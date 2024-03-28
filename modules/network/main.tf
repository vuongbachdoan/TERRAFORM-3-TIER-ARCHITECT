# Create VPC with tags
resource "aws_vpc" "vpc_lab_tf" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

# Create internet gateway with tags
resource "aws_internet_gateway" "lab_tf_igw" {
  vpc_id = aws_vpc.vpc_lab_tf.id

  tags = {
    Name = "lab_tf_igw"
  }
}

# Create public subnets with tags
resource "aws_subnet" "lab_tf_subnet_public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.vpc_lab_tf.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "LabTF: Public Subnet ${count.index + 1}"
  }
}

# Create private subnets with tags
resource "aws_subnet" "lab_tf_subnet_private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.vpc_lab_tf.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "LabTF: Private Subnet ${count.index + 1}"
  }
}

# Create public route table and associate with public subnets
resource "aws_route_table" "lab_tf_rt_public" {
  vpc_id = aws_vpc.vpc_lab_tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_tf_igw.id
  }
}

resource "aws_route_table_association" "lab_tf_rt_public_association" {
  count = length(aws_subnet.lab_tf_subnet_public)

  subnet_id = aws_subnet.lab_tf_subnet_public[count.index].id
  route_table_id = aws_route_table.lab_tf_rt_public.id
}

resource "aws_eip" "eip" {
  count = length(aws_subnet.lab_tf_subnet_private)
  vpc   = true
}

resource "aws_nat_gateway" "lab_tf_nat" {
  count         = length(aws_subnet.lab_tf_subnet_private)
  subnet_id     = aws_subnet.lab_tf_subnet_private[count.index].id
  allocation_id = aws_eip.eip[count.index].id
}

# Create private route table
resource "aws_route_table" "lab_tf_rt_private" {
  vpc_id = aws_vpc.vpc_lab_tf.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "lab_tf_rt_private_association" {
  count = length(aws_subnet.lab_tf_subnet_private)

  subnet_id = aws_subnet.lab_tf_subnet_private[count.index].id
  route_table_id = aws_route_table.lab_tf_rt_private.id
}

# Add route to private route table pointing to NAT gateways
resource "aws_route" "lab_tf_private_route" {
  count = length(aws_subnet.lab_tf_subnet_private)

  route_table_id = aws_route_table.lab_tf_rt_private.id
  nat_gateway_id = aws_nat_gateway.lab_tf_nat[count.index].id
  destination_cidr_block = aws_subnet.lab_tf_subnet_private[count.index].cidr_block
}
