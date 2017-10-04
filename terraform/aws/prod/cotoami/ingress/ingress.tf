module "environment" {
  source = "../../"
}

provider "aws" {
  region = "ap-northeast-1"
}


//
// Ingress ALB
//

resource "aws_alb" "cotoami" {
  name = "${module.environment.env_name}-cotoami-ingress"
  internal = false
  security_groups = ["${module.environment.sg_service_elb}"]
  subnets = ["${split(",", module.environment.subnets)}"]
}

resource "aws_alb_target_group" "cotoami" {
  name = "${module.environment.env_name}-cotoami-ingress"
  port = 80
  protocol = "HTTP"
  vpc_id = "${module.environment.vpc_id}"

  health_check {
    interval = 30
    path = "/healthz"
    port = 10254
    timeout = 20
    healthy_threshold = 3
    unhealthy_threshold = 2
  }
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
  certificate_arn = "${module.environment.ssl_certificate_wildcard_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.cotoami.arn}"
    type = "forward"
  }
}
