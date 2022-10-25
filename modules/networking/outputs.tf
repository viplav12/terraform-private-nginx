# Private security group id
output "private_sg_id" {
  value = aws_security_group.private-sg.id
}

# List of private subnet ids
output "private_subnetid" {
  value = aws_subnet.private.*.id
}

# ALB url
output "alb_url" {
  value = aws_lb.knab_alb.dns_name
}