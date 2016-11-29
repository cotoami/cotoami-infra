provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_route53_zone" "main" {
  name = "cotoa.me"
}

resource "aws_route53_zone" "dev" {
  name = "dev.cotoa.me"
}

resource "aws_route53_record" "main_dev_ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "dev.cotoa.me"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}"
  ]
}

resource "aws_route53_record" "dev_ns" {
  zone_id = "${aws_route53_zone.dev.zone_id}"
  name = "dev.cotoa.me"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}"
  ]
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "cotoa.me"
  type = "A"
  alias {
    name = "a630e3f1ab64711e6bf8506314825cf4-310288189.ap-northeast-1.elb.amazonaws.com"
    zone_id = "Z14GRHDCWA56QT"
    evaluate_target_health = true
  }
}
