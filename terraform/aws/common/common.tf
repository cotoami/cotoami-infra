provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_route53_zone" "main" {
  name = "cotoa.me"
}
