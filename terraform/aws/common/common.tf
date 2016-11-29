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
