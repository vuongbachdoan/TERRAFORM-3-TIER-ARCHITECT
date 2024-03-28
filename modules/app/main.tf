# Create security group for EC2 instances
resource "aws_security_group" "web_server_sg" {
  name = "web_server_sg"
  description = "Security group for web server instances"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create launch template for EC2 instances (with user data script)
resource "aws_launch_template" "web_server_lt" {
  name = "web_server_lt"

  image_id      = var.ami_id
  instance_type = var.instance_type

  # Associate security group with the launch template
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # User data script (ensuring single-line formatting and proper quoting)
  user_data = base64encode(
  <<-EOF
  #!/bin/bash
  sudo yum install curl -y && sudo yum install git -y && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && source ~/.bashrc && nvm install 16 && git clone -b main https://github.com/vuongbachdoan/LAB-3-TIER.git && cd LAB-3-TIER && npm install && npm start
  EOF
)
}


# Auto Scaling group using the launch template
resource "aws_autoscaling_group" "asg" {
  desired_capacity  = 2
  max_size          = 3
  min_size          = 1
  health_check_type = "EC2"

  launch_template {
    id = aws_launch_template.web_server_lt.id
    version = "$Latest"  # Use the latest version of the launch template
  }
  vpc_zone_identifier = var.private_subnet_ids

  tag {
    key   = "Name"
    value = "asg"
    propagate_at_launch = true
  }
}

# Load balancer and target group
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
}

resource "aws_lb_target_group" "lab-tf-app-target" {
  name     = "lab-tf-app-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.lab-tf-app-target.arn
  target_id        = aws_autoscaling_group.asg.id
  port             = 4200
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab-tf-app-target.arn
  }
}
