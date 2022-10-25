# Creating EC2 linux machine with user data scripts to deploy the application
resource "aws_instance" "linux_instance" {
  count                  = length(var.subnet_cidrs_private)
  subnet_id              = var.subnet_cidrs_private[count.index]
  vpc_security_group_ids = [var.private_security_id]
  ami                    = var.instance_ami_id
  instance_type          = var.instance_size

  user_data = file("./modules/scripts/user-data.sh")

  tags = {
    Name = "knab_linux_instance"
    Team = var.environment
  }
}

# Creating Target Group(TG) for Application Load Balancer(ALB)
resource "aws_lb_target_group" "knab_target_group" {
  name     = "knab-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    interval = 15
  }

  tags = {
    Name = "knab_target_group"
    Team = var.environment
  }
}

# Creating listener for ALB
resource "aws_lb_listener" "knab_lb_listener" {
  load_balancer_arn = var.alb_arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.knab_target_group.arn
  }

  tags = {
    Name = "knab_lb_listener"
    Team = var.environment
  }
}

# Attaching TG to EC2 instances
resource "aws_lb_target_group_attachment" "knab_target_group_attachment" {
  count            = length(var.subnet_cidrs_private)
  target_group_arn = aws_lb_target_group.knab_target_group.arn
  target_id        = element(aws_instance.linux_instance.*.id, count.index)
}