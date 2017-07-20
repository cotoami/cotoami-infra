module "environment" {
  source = "../"
}

provider "aws" {
  region = "ap-northeast-1"
}

# This sg should be applied to the node instance group via
#   $ kops edit ig nodes
# https://github.com/kubernetes/kops/issues/1628
resource "aws_security_group" "nodes" {
  vpc_id = "${module.environment.vpc_id}"
  name = "additional.nodes.${module.environment.cluster_name}"
  description = "Additional security group for nodes"
  tags {
    Name = "additional.nodes.${module.environment.cluster_name}"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", module.environment.authroized_cidr_blocks)}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.service_elb.id}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.internal_service_elb.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service_elb" {
  vpc_id = "${module.environment.vpc_id}"
  name = "k8s-service-elb"
  description = "k8s-service-elb"
  tags {
    Name = "k8s-service-elb"
  }
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

resource "aws_security_group" "internal_service_elb" {
  vpc_id = "${module.environment.vpc_id}"
  name = "k8s-internal-service-elb"
  description = "k8s-internal-service-elb"
  tags {
    Name = "k8s-internal-service-elb"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${split(",", module.environment.authroized_cidr_blocks)}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${split(",", module.environment.authroized_cidr_blocks)}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
