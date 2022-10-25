# Create the VPC
resource "aws_vpc" "knab_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "knab_vpc"
    Environment = var.environment
  }
}

# Create two public subnet in two availability zone for hosting the load balancer
resource "aws_subnet" "public" {
  count = length(var.subnet_cidrs_public)
  vpc_id     = aws_vpc.knab_vpc.id
  cidr_block = var.subnet_cidrs_public[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "knab_public_subnet"
    Environment = var.environment
  }
}

# Create two private subnet in two availability zone for hosting the instance
resource "aws_subnet" "private" {
  count = length(var.subnet_cidrs_private)
  vpc_id     = aws_vpc.knab_vpc.id
  cidr_block = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "knab_private_subnet"
    Environment = var.environment
  }
}

# Internet gateway to route the traffic from internet
resource "aws_internet_gateway" "knab_igw" {
  vpc_id = aws_vpc.knab_vpc.id

  tags = {
    Name = "knab_igw"
    Environment = var.environment
  }
}

# Route table for public subnet and its association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.knab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.knab_igw.id
  }

  tags = {
    Name = "knab_public_rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(var.subnet_cidrs_public)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Create eip for the insance
resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

# Create NAT gateway
resource "aws_nat_gateway" "ngw_1a" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id = element(aws_subnet.public.*.id, 0)

  tags = {
    Name = "NAT-Gateway-1a"
    Environment = var.environment
  }
}

# Create private Route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.knab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_1a.id
  }
  tags = {
    Name = "knab_private_rt"
    Environment = var.environment
  }
}

# Associating route table with private subnet
resource "aws_route_table_association" "private_rt_association" {
  count = length(var.subnet_cidrs_private)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

# Network access control list for private subnets
resource "aws_network_acl" "knab_nacl_private" {
  vpc_id     = aws_vpc.knab_vpc.id
  subnet_ids = aws_subnet.private.*.id
  # Outgoing rule to allow traffic to download instances update and application
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
  # Inbound rule for allowing port 80 and 443 from public subnet
  ingress {
    rule_no   = 300
    protocol  = "tcp"
    action    = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port   = 65535
  }
  dynamic "ingress" {
    for_each = range(length(var.subnet_cidrs_public))
    iterator = i
    content {
      rule_no    = 100 + i.value
      protocol   = "tcp"
      action     = "allow"
      cidr_block = var.subnet_cidrs_public[i.value]
      from_port  = 80
      to_port    = 80
    }
  }

  dynamic "ingress" {
    for_each = range(length(var.subnet_cidrs_public))
    iterator = j
    content {
      rule_no    = 200 + j.value
      protocol   = "tcp"
      action     = "allow"
      cidr_block = var.subnet_cidrs_public[j.value]
      from_port  = 443
      to_port    = 443
    }
  }
  tags = {
    Name = "nacl-private"
    Environment = var.environment
  }
}

# Public security Group
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.knab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags =  {
    Name = "knab_public-sg"
    Environment = var.environment
  }
}

# Private security Group
resource "aws_security_group" "private-sg"{
  name = "private-sg"
  description = "Allow traffic from private subnet"
  vpc_id = aws_vpc.knab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    security_groups = [aws_security_group.public-sg.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "knab_private-sg"
    Environment = var.environment
  }
}

# Creating Application load Balancer(ALB)
resource "aws_lb" "knab_alb" {
  name = "knab-alb"
  security_groups = [aws_security_group.public-sg.id]
  load_balancer_type = "application"
  subnets = aws_subnet.public.*.id
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "knab_alb"
    Environment = var.environment
  }
}

module "instance" {
  source = "../instance"
  environment = var.environment
  subnet_cidrs_private = aws_subnet.private.*.id
  vpc_id = aws_vpc.knab_vpc.id
  private_security_id = aws_security_group.private-sg.id
  private_subnetid = aws_subnet.private.*.id
  alb_arn = aws_lb.knab_alb.arn
}

