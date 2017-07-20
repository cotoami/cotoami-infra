provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_route53_zone" "main" {
  name = "cotoa.me"
}

resource "aws_route53_zone" "k8s" {
  name = "k8s.cotoa.me"
}

resource "aws_route53_record" "main_k8s_ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "k8s.cotoa.me"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.k8s.name_servers.0}",
    "${aws_route53_zone.k8s.name_servers.1}",
    "${aws_route53_zone.k8s.name_servers.2}",
    "${aws_route53_zone.k8s.name_servers.3}"
  ]
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "cotoa.me"
  type = "A"
  alias {
    name = "cotoami-633529141.ap-northeast-1.elb.amazonaws.com"
    zone_id = "Z14GRHDCWA56QT"
    evaluate_target_health = true
  }
}
