

###  Find machine image
data "aws_ami" "server_ami" {
   most_recent = true
 owners = ["309956199498"]

 filter {
   name = "name"
   values = var.data_values
 }
}

####  vpc resource
resource "aws_vpc" "BrontechPubvpc" {
  cidr_block = var.General_variables.app_key
  enable_dns_hostnames = true
  tags = {
    Name = "BrontechPubvpc"
  }
}

resource "aws_internet_gateway" "BrontechIGW" {
  vpc_id = aws_vpc.BrontechPubvpc.id
  tags = {
    Name = "BrontechIGW"
  }
}
resource "aws_route_table" "BrontechPubRT" {
  vpc_id = aws_vpc.BrontechPubvpc.id

  route {
    cidr_block =  local.cidrblocks[0]
    gateway_id = aws_internet_gateway.BrontechIGW.id
  }
  tags = {
    Name = "BrontechPubRT"
    }
    }

resource "aws_route_table" "BrontechPritRT" {
  vpc_id = aws_vpc.BrontechPubvpc.id
  tags = {
    Name = "BrontechPritRT"
  }
}

resource "aws_route_table_association" "BrontechPubAS" {
  subnet_id      = aws_subnet.BrontechPubSN.id
  route_table_id = aws_route_table.BrontechPubRT.id
}

resource "aws_route_table_association" "BrontechPritAS" {
  subnet_id      = aws_subnet.BrontechPritSN.id
  route_table_id = aws_route_table.BrontechPritRT.id
}
resource "aws_subnet" "BrontechPubSN" {
  vpc_id            = aws_vpc.BrontechPubvpc.id
  cidr_block        = var.ssh-http.ssh[1]
  availability_zone = var.instance.subnet_az[0]
  tags = {
    Name = "BrontechPubSN"
  }
}

 resource "aws_subnet" "BrontechPritSN" {
  vpc_id            = aws_vpc.BrontechPubvpc.id
  cidr_block        = var.PrivSubCidr
  availability_zone = var.private_az
  tags = {
    Name = "BrontechPritSN"
  }
 }

   resource "aws_security_group" "Web_Traffic" {
   for_each   = local.security_groups
   name        = each.value.name
   description = each.value.description
   vpc_id      = aws_vpc.BrontechPubvpc.id

   dynamic "ingress" {
   for_each = each.value.ingress
    content {
    from_port     = ingress.value.from_port
    to_port       = ingress.value.to_port
    protocol      = ingress.value.protocol
      cidr_blocks  = [ingress.value.cidr_blocks]
      }

    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.cidrblocks[0]]
  }
  tags = {
    Name = "allow_Web_Traffic"
   }
   }

 resource "aws_instance" "JJtectWeb" {
   count                = "${var.enviroment == "prod" ? 0 : 1}"
  ami               = "ami-0ab4d1e9cf9a1215a"
  instance_type     = var.instance.instance_types[0]
  vpc_security_group_ids = [aws_security_group.Web_Traffic["web_sg"].id]
  subnet_id = aws_subnet.BrontechPubSN.id
  associate_public_ip_address  = "${var.public_ip == "true" ? true : false}"
  key_name          = var.General_variables.web_keypair
  user_data = "${var.user_data_path != "" ? file(var.user_data_path) : ""}"#file(var.user_data_path)
  tags = {
    Name = "JJtectWeb"
  }
  lifecycle {
  create_before_destroy = true
}
  }

 resource "aws_instance" "JJtectApp" {
   count                = "${var.enviroment == "prod" ? 0 : 1}"
  ami                    = "ami-0ab4d1e9cf9a1215a"
  instance_type          = var.instance.instance_types[0]
  vpc_security_group_ids = [aws_security_group.Web_Traffic["backend_sg"].id]
  subnet_id              = aws_subnet.BrontechPritSN.id
  key_name               = var.General_variables.web_keypair
  tags = local.common_tags
 }

 resource "aws_eip" "BrontechEP" {
  vpc                     =  true
  depends_on              = [aws_internet_gateway.BrontechIGW]
}

resource "aws_lb" "alb" {
  name                       = "${var.alb-name}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.Web_Traffic["alb_sg"].id]
  subnets                    = ["${aws_subnet.BrontechPubSN.id}", "${aws_subnet.BrontechPritSN.id}"]
  enable_deletion_protection = false

  tags = "${local.common_tags}"
}

resource "aws_lb_target_group" "lb_target" {
name_prefix = "${var.target-group-name}"
port        = 80
protocol    = "HTTP"
vpc_id      = "${aws_vpc.BrontechPubvpc.id}"

health_check {
  interval            = "${var.health_check_interval}"
  healthy_threshold   = "${var.health_check_threshold}"
  unhealthy_threshold = "${var.health_check_threshold}"
  timeout             = "${var.health_check_threshold}"
  path                = "${var.health-check-path}"
  port                = "${var.health-check-port}"
  matcher             = "200"
}

tags = "${local.common_tags}"
}

 resource "aws_lb_listener" "lb_listener" {
 count = "${var.use_https_only == "true" ? 0 : 1}"

 load_balancer_arn = "${aws_lb.alb.arn}"
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = "${aws_lb_target_group.lb_target.arn}"
 }
}

resource "aws_lb_listener" "lb_listener_redirect_http" {
count = "${var.use_https_only == "true" ? 1 : 0}"

load_balancer_arn = "${aws_lb.alb.arn}"
port              = "80"
protocol          = "HTTP"

default_action  {
  type = "redirect"

  redirect {
    port        = "443"
    protocol    = "HTTPS"
    status_code = "HTTP_301"
  }
}
}

resource "aws_lb_listener" "lb_listener_https" {
count = "${var.ssl_certificate_arn != "" ? 1 : 0}"

load_balancer_arn = "${aws_lb.alb.arn}"
port              = "443"
protocol          = "HTTPS"
ssl_policy        = "ELBSecurityPolicy-2016-08"
certificate_arn   = "${var.ssl_certificate_arn}"

default_action  {
  type             = "forward"
  target_group_arn = "${aws_lb_target_group.lb_target.arn}"
}
}

# Launch configuration
# Configures the machines that are deployed
#
resource "aws_launch_configuration" "launch_config" {
 name_prefix                 = "${var.launch-config-name}"
 image_id                    = "${data.aws_ami.server_ami.image_id}"
 instance_type               = "${var.instance-type}"
 #iam_instance_profile        = "${var.iam-role-name != "" ? var.iam-role-name : ""}"
 key_name                    = var.General_variables.web_keypair
 user_data                   = "${var.user_data_path != "" ? file(var.user_data_path) : ""}"
 associate_public_ip_address = "${var.public_ip != "true" ? true : false}"
 security_groups             = [aws_security_group.Web_Traffic["web_sg"].id]
}

# AutoScaling Group
# Scale (up/down) the number of machines, based on some criteria
#
resource "aws_autoscaling_group" "asg" {
 # name                      = "${var.asg-name}"
 name                      = "${aws_launch_configuration.launch_config.name}"
 min_size                  = var.asg-min-max-def-size.asg-num[0]
 desired_capacity          = var.asg-min-max-def-size.asg-num[1]
 max_size                  = var.asg-min-max-def-size.asg-num[2]
 launch_configuration      = "${aws_launch_configuration.launch_config.name}"
 vpc_zone_identifier       = ["${aws_subnet.BrontechPubSN.id}", "${aws_subnet.BrontechPritSN.id}"]
 target_group_arns         = ["${aws_lb_target_group.lb_target.arn}"]
 health_check_grace_period = "${var.health_check_grace_per}"
 health_check_type         = "ELB"
 min_elb_capacity          = 2

 lifecycle {
   create_before_destroy = true
 }
}
# my personal terraform commands
# IF YOU WANNA LIST JUST ONE RESOURCE YOU
# terraform state show aws_instance.JJtectApp
# IF YOU WANNA LIST ALL THE RESOURCE
# terraform stats lists
# if there's a need to delete justs on resource
# terraform destroy -target "resource name"
# to assign just one resource
# terraform apply -target "resource name"
# to pass a varable via command line
# tarraform apply -var "variableName=value --auto-approve"
# user an concomon var-file
# terraform -var-file "name for the var-file"
# to create a local in order to reduce redundacy in ur code
# locals {
#"name of your locals" = "local values"
# and to reference it
# Name= "${local.setup_name}.any resource"
# tarrfrom taint "resouce name"
#terraform import aws_security_group.Web_Traffic sg-0a5e2047980c694ab
