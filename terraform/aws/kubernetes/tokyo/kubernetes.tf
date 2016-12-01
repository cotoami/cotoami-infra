provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_autoscaling_group" "master-ap-northeast-1a-masters-tokyo-k8s-cotoa-me" {
  name = "master-ap-northeast-1a.masters.tokyo.k8s.cotoa.me"
  launch_configuration = "${aws_launch_configuration.master-ap-northeast-1a-masters-tokyo-k8s-cotoa-me.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-tokyo-k8s-cotoa-me.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "tokyo.k8s.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "master-ap-northeast-1a.masters.tokyo.k8s.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/master"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-tokyo-k8s-cotoa-me" {
  name = "nodes.tokyo.k8s.cotoa.me"
  launch_configuration = "${aws_launch_configuration.nodes-tokyo-k8s-cotoa-me.id}"
  max_size = 2
  min_size = 2
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-tokyo-k8s-cotoa-me.id}", "${aws_subnet.ap-northeast-1c-tokyo-k8s-cotoa-me.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "tokyo.k8s.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "nodes.tokyo.k8s.cotoa.me"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/node"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-events-tokyo-k8s-cotoa-me" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "ap-northeast-1a.etcd-events.tokyo.k8s.cotoa.me"
    "k8s.io/etcd/events" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-main-tokyo-k8s-cotoa-me" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "ap-northeast-1a.etcd-main.tokyo.k8s.cotoa.me"
    "k8s.io/etcd/main" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-tokyo-k8s-cotoa-me" {
  name = "masters.tokyo.k8s.cotoa.me"
  roles = ["${aws_iam_role.masters-tokyo-k8s-cotoa-me.name}"]
}

resource "aws_iam_instance_profile" "nodes-tokyo-k8s-cotoa-me" {
  name = "nodes.tokyo.k8s.cotoa.me"
  roles = ["${aws_iam_role.nodes-tokyo-k8s-cotoa-me.name}"]
}

resource "aws_iam_role" "masters-tokyo-k8s-cotoa-me" {
  name = "masters.tokyo.k8s.cotoa.me"
  assume_role_policy = "${file("data/aws_iam_role_masters.tokyo.k8s.cotoa.me_policy")}"
}

resource "aws_iam_role" "nodes-tokyo-k8s-cotoa-me" {
  name = "nodes.tokyo.k8s.cotoa.me"
  assume_role_policy = "${file("data/aws_iam_role_nodes.tokyo.k8s.cotoa.me_policy")}"
}

resource "aws_iam_role_policy" "masters-tokyo-k8s-cotoa-me" {
  name = "masters.tokyo.k8s.cotoa.me"
  role = "${aws_iam_role.masters-tokyo-k8s-cotoa-me.name}"
  policy = "${file("data/aws_iam_role_policy_masters.tokyo.k8s.cotoa.me_policy")}"
}

resource "aws_iam_role_policy" "nodes-tokyo-k8s-cotoa-me" {
  name = "nodes.tokyo.k8s.cotoa.me"
  role = "${aws_iam_role.nodes-tokyo-k8s-cotoa-me.name}"
  policy = "${file("data/aws_iam_role_policy_nodes.tokyo.k8s.cotoa.me_policy")}"
}

resource "aws_internet_gateway" "tokyo-k8s-cotoa-me" {
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "tokyo.k8s.cotoa.me"
  }
}

resource "aws_key_pair" "kubernetes-tokyo-k8s-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7" {
  key_name = "kubernetes.tokyo.k8s.cotoa.me-37:f0:fe:2d:a9:48:a7:90:ce:33:f9:f1:d9:92:38:c7"
  public_key = "${file("data/aws_key_pair_kubernetes.tokyo.k8s.cotoa.me-37f0fe2da948a790ce33f9f1d99238c7_public_key")}"
}

resource "aws_launch_configuration" "master-ap-northeast-1a-masters-tokyo-k8s-cotoa-me" {
  name_prefix = "master-ap-northeast-1a.masters.tokyo.k8s.cotoa.me-"
  image_id = "ami-a19c3ac0"
  instance_type = "m3.medium"
  key_name = "${aws_key_pair.kubernetes-tokyo-k8s-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-tokyo-k8s-cotoa-me.id}"
  security_groups = ["${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_master-ap-northeast-1a.masters.tokyo.k8s.cotoa.me_user_data")}"
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

resource "aws_launch_configuration" "nodes-tokyo-k8s-cotoa-me" {
  name_prefix = "nodes.tokyo.k8s.cotoa.me-"
  image_id = "ami-a19c3ac0"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.kubernetes-tokyo-k8s-cotoa-me-37f0fe2da948a790ce33f9f1d99238c7.id}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes-tokyo-k8s-cotoa-me.id}"
  security_groups = ["${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_nodes.tokyo.k8s.cotoa.me_user_data")}"
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
  route_table_id = "${aws_route_table.tokyo-k8s-cotoa-me.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.tokyo-k8s-cotoa-me.id}"
}

resource "aws_route_table" "tokyo-k8s-cotoa-me" {
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "tokyo.k8s.cotoa.me"
  }
}

resource "aws_route_table_association" "ap-northeast-1a-tokyo-k8s-cotoa-me" {
  subnet_id = "${aws_subnet.ap-northeast-1a-tokyo-k8s-cotoa-me.id}"
  route_table_id = "${aws_route_table.tokyo-k8s-cotoa-me.id}"
}

resource "aws_route_table_association" "ap-northeast-1c-tokyo-k8s-cotoa-me" {
  subnet_id = "${aws_subnet.ap-northeast-1c-tokyo-k8s-cotoa-me.id}"
  route_table_id = "${aws_route_table.tokyo-k8s-cotoa-me.id}"
}

resource "aws_security_group" "masters-tokyo-k8s-cotoa-me" {
  name = "masters.tokyo.k8s.cotoa.me"
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  description = "Security group for masters"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "masters.tokyo.k8s.cotoa.me"
  }
}

resource "aws_security_group" "nodes-tokyo-k8s-cotoa-me" {
  name = "nodes.tokyo.k8s.cotoa.me"
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  description = "Security group for nodes"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "nodes.tokyo.k8s.cotoa.me"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  source_security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "https-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-tokyo-k8s-cotoa-me.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-tokyo-k8s-cotoa-me.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-northeast-1a-tokyo-k8s-cotoa-me" {
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  cidr_block = "172.20.32.0/19"
  availability_zone = "ap-northeast-1a"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "ap-northeast-1a.tokyo.k8s.cotoa.me"
  }
}

resource "aws_subnet" "ap-northeast-1c-tokyo-k8s-cotoa-me" {
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  cidr_block = "172.20.96.0/19"
  availability_zone = "ap-northeast-1c"
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "ap-northeast-1c.tokyo.k8s.cotoa.me"
  }
}

resource "aws_vpc" "tokyo-k8s-cotoa-me" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "tokyo.k8s.cotoa.me"
  }
}

resource "aws_vpc_dhcp_options" "tokyo-k8s-cotoa-me" {
  domain_name = "ap-northeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    KubernetesCluster = "tokyo.k8s.cotoa.me"
    Name = "tokyo.k8s.cotoa.me"
  }
}

resource "aws_vpc_dhcp_options_association" "tokyo-k8s-cotoa-me" {
  vpc_id = "${aws_vpc.tokyo-k8s-cotoa-me.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.tokyo-k8s-cotoa-me.id}"
}