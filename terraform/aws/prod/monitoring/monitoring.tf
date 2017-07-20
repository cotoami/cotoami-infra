module "environment" {
  source = "../"
}

provider "aws" {
  region = "ap-northeast-1"
}


//
// alertmanager
//

resource "aws_route53_record" "alertmanager" {
  zone_id = "${module.environment.zone_id}"
  name = "alertmanager.cotoa.me"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.alertmanager.dns_name}"]
}

resource "aws_elb" "alertmanager" {
  name = "${module.environment.env_name}-alertmanager"
  cross_zone_load_balancing = true
  subnets = ["${split(",", module.environment.subnets)}"]
  security_groups = ["${module.environment.sg_internal_service_elb}"]
  listener {
    instance_port = 30001
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${module.environment.ssl_certificate_wildcard_id}"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:30001/alertmanager/"
    interval = 30
  }
}


//
// prometheus
//

resource "aws_route53_record" "prometheus" {
  zone_id = "${module.environment.zone_id}"
  name = "prometheus.cotoa.me"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.prometheus.dns_name}"]
}

resource "aws_elb" "prometheus" {
  name = "${module.environment.env_name}-prometheus"
  cross_zone_load_balancing = true
  subnets = ["${split(",", module.environment.subnets)}"]
  security_groups = ["${module.environment.sg_internal_service_elb}"]
  listener {
    instance_port = 30002
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${module.environment.ssl_certificate_wildcard_id}"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:30002/graph"
    interval = 30
  }
}


//
// grafana
//

resource "aws_route53_record" "grafana" {
  zone_id = "${module.environment.zone_id}"
  name = "grafana.cotoa.me"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.grafana.dns_name}"]
}

resource "aws_elb" "grafana" {
  name = "${module.environment.env_name}-grafana"
  cross_zone_load_balancing = true
  subnets = ["${split(",", module.environment.subnets)}"]
  security_groups = ["${module.environment.sg_internal_service_elb}"]
  listener {
    instance_port = 30003
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${module.environment.ssl_certificate_wildcard_id}"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:30003/"
    interval = 30
  }
}
