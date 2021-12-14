resource "aws_key_pair" "ec2_web" {
  key_name_prefix = "instance_pub_key"
  public_key = file(var.path_to_pub_key)
}


resource "aws_instance" "dev_only" {
  count = var.environment == "dev" ? 1 : 0
  ami                         = data.aws_ami.latest_ver.id
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public1.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_web.key_name
  vpc_security_group_ids      = [aws_security_group.web_asg.id]

  user_data = templatefile("nginx_user_data.sh.tpl", {
    name   = "pavel",
    object = "you",
    game   = "dota",
    heroes = ["SPIRIT BREAKER", "NAGA SIREN", "WINTER WYVERN", "JAKIRO", "JUGGERNAUT"]
  })

  lifecycle {
    # prevent_destroy = true
    # create_before_destroy = false
    ignore_changes = [ami]
  }

  tags = {
    Name = "Test web instance"
  }
}

# resource "aws_eip" "web_server_ip" {
#   instance = aws_instance.test.id
#   depends_on = [
#     aws_instance.test
#   ]
# }

resource "aws_launch_template" "web_app_template" {
  name_prefix = "web_app_template_"
  image_id = data.aws_ami.latest_ver.id
  instance_initiated_shutdown_behavior = "stop"
  instance_type = var.instance_type
  key_name = aws_key_pair.ec2_web.key_name
  vpc_security_group_ids = [aws_security_group.web_asg.id]

  tags = local.curr_env_tags
    
  user_data = base64encode(templatefile(var.path_to_user_data, var.user_data_template_fill))
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_asg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

}

resource "aws_lb_target_group" "web_tg" {
  name                 = "web-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.default_vpc.id
  deregistration_delay = 20
  target_type          = "instance"
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 10
    path                = "/"
  }
}


resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                = "ASG_${aws_launch_template.web_app_template.name}"
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  max_size         = var.max_instances_scaling
  min_size         = var.min_instances_scaling
  desired_capacity = var.desired_instances_scaling
  health_check_grace_period = 60
  health_check_type         = "ELB"
  #   health_check_type         = "EC2"
  #   force_delete              = true
  target_group_arns = [aws_lb_target_group.web_tg.arn]
  launch_template {
    id      = aws_launch_template.web_app_template.id
    version = aws_launch_template.web_app_template.latest_version
  }

  termination_policies = ["OldestLaunchTemplate"]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 20
    }
  }

  dynamic "tag" {
      for_each = local.curr_env_tags
      content {
          key = tag.key
          value = tag.value
          propagate_at_launch = true
      }
  }
}

resource "null_resource" "demonstation" {
  provisioner "local-exec" {
     command = "echo \"This is test of local-exec and null resource\""
  }
}