terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = var.ssh-pubkey
}

resource "aws_instance" "instance" {
  ami = "ami-0964717712e85fa54"  
  instance_type = "m5.large"
  count = 2 

  subnet_id = "${aws_subnet.subnet-1.id}"
  associate_public_ip_address = true

  security_groups = ["${aws_security_group.main-sg.id}"]

  key_name = "ssh-key"
  
  tags = {
    Name = "EC2_instance-${count.index}"
  }
}

resource "aws_lb" "app" {
  name               = "main-app-lb"
  internal           = false
  load_balancer_type = "network"
  subnets           = ["${aws_subnet.subnet-1.id}"]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "26657"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }
}

resource "aws_lb_target_group" "instance" {
  name     = "instance-tg-lb"
  vpc_id = aws_vpc.subnet.id
  port     = 26657
  protocol = "TCP"

  health_check {
    port     = 26657
    protocol = "TCP"
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "instance" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.instance.arn
  target_id        = aws_instance.instance[count.index].id
  port             = 26657
}

