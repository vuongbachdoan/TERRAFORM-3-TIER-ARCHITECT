# Define outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc_lab_tf.id
}

output "public_subnet_ids" {
  value = aws_subnet.lab_tf_subnet_public[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value = aws_subnet.lab_tf_subnet_private[*].id
  description = "List of private subnet IDs"
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.lab_tf_nat[*].id
  description = "List of NAT gateway IDs"
}
