provider "aws" {
  region = "ap-northeast-1"
}

variable "vpc_id" {
  default = "vpc-0d3feb69"
}
variable "subnets" {
  default = "subnet-f1851387,subnet-97dc05cf"
}

resource "aws_security_group" "cotoami" {
  vpc_id = "${var.vpc_id}"
  name = "cotoami-elb"
  description = "cotoami-elb"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
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

resource "aws_alb" "cotoami" {
  name = "cotoami"
  internal = false
  security_groups = ["${aws_security_group.cotoami.id}"]
  subnets = ["${split(",", var.subnets)}"]
}

resource "aws_alb_listener" "cotoami_http" {
  load_balancer_arn = "${aws_alb.cotoami.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.cotoami.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "cotoami_https" {
  load_balancer_arn = "${aws_alb.cotoami.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "arn:aws:acm:ap-northeast-1:207588786415:certificate/ad07312b-d416-4a53-8031-49e3ce78cd0f"

  default_action {
    target_group_arn = "${aws_alb_target_group.cotoami.arn}"
    type = "forward"
  }
}

resource "aws_alb_target_group" "cotoami" {
  name = "cotoami"
  port = 32148
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}
