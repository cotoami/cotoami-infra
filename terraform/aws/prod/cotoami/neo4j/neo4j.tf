module "environment" {
  source = "../../"
}

provider "aws" {
  region = "ap-northeast-1"
}


//
// EBS for PersistentVolume
//

resource "aws_ebs_volume" "neo4j" {
  availability_zone = "ap-northeast-1c"
  size = 200
  type = "gp2"
  tags {
    Name = "cotoami-prod-neo4j"
  }
}


//
// Route53: neo4j.cotoa.me
//

resource "aws_route53_record" "neo4j" {
  zone_id = "${module.environment.zone_id}"
  name = "neo4j.cotoa.me"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_alb.neo4j.dns_name}"]
}


//
// ALB
//

resource "aws_alb" "neo4j" {
  name = "${module.environment.env_name}-neo4j"
  internal = false
  security_groups = ["${module.environment.sg_internal_service_elb}"]
  subnets = ["${split(",", module.environment.subnets)}"]
}

// ALB target groups

resource "aws_alb_target_group" "neo4j_http" {
  name = "${module.environment.env_name}-neo4j-http"
  port = 30201
  protocol = "HTTP"
  vpc_id = "${module.environment.vpc_id}"

  health_check {
    interval = 30
    path = "/db/data/"
    timeout = 20
    healthy_threshold = 3
    unhealthy_threshold = 2
  }
}

resource "aws_alb_target_group" "neo4j_bolt" {
  name = "${module.environment.env_name}-neo4j-bolt"
  port = 30202
  protocol = "HTTP"
  vpc_id = "${module.environment.vpc_id}"

  health_check {
    matcher = "400"
  }
}

// ALB listeners

resource "aws_alb_listener" "neo4j_https" {
  load_balancer_arn = "${aws_alb.neo4j.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${module.environment.ssl_certificate_wildcard_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.neo4j_http.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "neo4j_bolt" {
  load_balancer_arn = "${aws_alb.neo4j.arn}"
  port = "7687"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${module.environment.ssl_certificate_wildcard_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.neo4j_bolt.arn}"
    type = "forward"
  }
}
