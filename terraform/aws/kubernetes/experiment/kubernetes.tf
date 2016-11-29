provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_autoscaling_group" "master-ap-northeast-1a-masters-experiment-dev-cotoa-me" {
  name = "master-ap-northeast-1a.masters.experiment.dev.cotoa.me"
  launch_configuration = "${aws_launch_configuration.master-ap-northeast-1a-masters-experiment-dev-cotoa-me.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-experiment-dev-cotoa-me.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "experiment.dev.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "master-ap-northeast-1a.masters.experiment.dev.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/master"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-experiment-dev-cotoa-me" {
  name = "nodes.experiment.dev.cotoa.me"
  launch_configuration = "${aws_launch_configuration.nodes-experiment-dev-cotoa-me.id}"
  max_size = 2
  min_size = 2
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-experiment-dev-cotoa-me.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "experiment.dev.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "nodes.experiment.dev.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/node"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-events-experiment-dev-cotoa-me" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "ap-northeast-1a.etcd-events.experiment.dev.cotoa.me"
    "k8s.io/etcd/events" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-main-experiment-dev-cotoa-me" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "ap-northeast-1a.etcd-main.experiment.dev.cotoa.me"
    "k8s.io/etcd/main" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-experiment-dev-cotoa-me" {
  name = "masters.experiment.dev.cotoa.me"
  roles = ["${aws_iam_role.masters-experiment-dev-cotoa-me.name}"]
}

resource "aws_iam_instance_profile" "nodes-experiment-dev-cotoa-me" {
  name = "nodes.experiment.dev.cotoa.me"
  roles = ["${aws_iam_role.nodes-experiment-dev-cotoa-me.name}"]
}

resource "aws_iam_role" "masters-experiment-dev-cotoa-me" {
  name = "masters.experiment.dev.cotoa.me"
  assume_role_policy = "${file("data/aws_iam_role_masters.experiment.dev.cotoa.me_policy")}"
}

resource "aws_iam_role" "nodes-experiment-dev-cotoa-me" {
  name = "nodes.experiment.dev.cotoa.me"
  assume_role_policy = "${file("data/aws_iam_role_nodes.experiment.dev.cotoa.me_policy")}"
}

resource "aws_iam_role_policy" "masters-experiment-dev-cotoa-me" {
  name = "masters.experiment.dev.cotoa.me"
  role = "${aws_iam_role.masters-experiment-dev-cotoa-me.name}"
  policy = "${file("data/aws_iam_role_policy_masters.experiment.dev.cotoa.me_policy")}"
}

resource "aws_iam_role_policy" "nodes-experiment-dev-cotoa-me" {
  name = "nodes.experiment.dev.cotoa.me"
  role = "${aws_iam_role.nodes-experiment-dev-cotoa-me.name}"
  policy = "${file("data/aws_iam_role_policy_nodes.experiment.dev.cotoa.me_policy")}"
}

resource "aws_internet_gateway" "experiment-dev-cotoa-me" {
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "experiment.dev.cotoa.me"
  }
}

resource "aws_key_pair" "kubernetes-experiment-dev-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7" {
  key_name = "kubernetes.experiment.dev.cotoa.me-37:f0:fe:2d:a9:48:a7:90:ce:33:f9:f1:d9:92:38:c7"
  public_key = "${file("data/aws_key_pair_kubernetes.experiment.dev.cotoa.me-37f0fe2da948a790ce33f9f1d99238c7_public_key")}"
}

resource "aws_launch_configuration" "master-ap-northeast-1a-masters-experiment-dev-cotoa-me" {
  name_prefix = "master-ap-northeast-1a.masters.experiment.dev.cotoa.me-"
  image_id = "ami-a19c3ac0"
  instance_type = "m3.medium"
  key_name = "${aws_key_pair.kubernetes-experiment-dev-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-experiment-dev-cotoa-me.id}"
  security_groups = ["${aws_security_group.masters-experiment-dev-cotoa-me.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_master-ap-northeast-1a.masters.experiment.dev.cotoa.me_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  ephemeral_block_device = {
    device_name = "/dev/sdc"
    virtual_name = "ephemeral0"
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-experiment-dev-cotoa-me" {
  name_prefix = "nodes.experiment.dev.cotoa.me-"
  image_id = "ami-a19c3ac0"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.kubernetes-experiment-dev-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7.id}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes-experiment-dev-cotoa-me.id}"
  security_groups = ["${aws_security_group.nodes-experiment-dev-cotoa-me.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_nodes.experiment.dev.cotoa.me_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id = "${aws_route_table.experiment-dev-cotoa-me.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.experiment-dev-cotoa-me.id}"
}

resource "aws_route_table" "experiment-dev-cotoa-me" {
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "experiment.dev.cotoa.me"
  }
}

resource "aws_route_table_association" "ap-northeast-1a-experiment-dev-cotoa-me" {
  subnet_id = "${aws_subnet.ap-northeast-1a-experiment-dev-cotoa-me.id}"
  route_table_id = "${aws_route_table.experiment-dev-cotoa-me.id}"
}

resource "aws_security_group" "masters-experiment-dev-cotoa-me" {
  name = "masters.experiment.dev.cotoa.me"
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  description = "Security group for masters"
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "masters.experiment.dev.cotoa.me"
  }
}

resource "aws_security_group" "nodes-experiment-dev-cotoa-me" {
  name = "nodes.experiment.dev.cotoa.me"
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  description = "Security group for nodes"
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "nodes.experiment.dev.cotoa.me"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "https-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-experiment-dev-cotoa-me.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-experiment-dev-cotoa-me.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-northeast-1a-experiment-dev-cotoa-me" {
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  cidr_block = "172.20.32.0/19"
  availability_zone = "ap-northeast-1a"
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "ap-northeast-1a.experiment.dev.cotoa.me"
  }
}

resource "aws_vpc" "experiment-dev-cotoa-me" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "experiment.dev.cotoa.me"
  }
}

resource "aws_vpc_dhcp_options" "experiment-dev-cotoa-me" {
  domain_name = "ap-northeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    KubernetesCluster = "experiment.dev.cotoa.me"
    Name = "experiment.dev.cotoa.me"
  }
}

resource "aws_vpc_dhcp_options_association" "experiment-dev-cotoa-me" {
  vpc_id = "${aws_vpc.experiment-dev-cotoa-me.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.experiment-dev-cotoa-me.id}"
}