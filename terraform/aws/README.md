Installing Kubernetes on AWS with kops
======================================

* [Kubernetes - Installing Kubernetes on AWS with kops](http://kubernetes.io/docs/getting-started-guides/kops/ "Kubernetes - Installing Kubernetes on AWS with kops")

## Install kops

On MacOS:
```
$ wget https://github.com/kubernetes/kops/releases/download/v1.4.1/kops-darwin-amd64
$ chmod +x kops-darwin-amd64
$ mv kops-darwin-amd64 /usr/local/bin/kops
```

## Create a hosted zone in Route 53

* Domain name: `k8s.example.com`

Terraform example:
```
resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_route53_zone" "k8s" {
  name = "k8s.example.com"
}

resource "aws_route53_record" "main_k8s_ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "k8s.example.com"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.k8s.name_servers.0}",
    "${aws_route53_zone.k8s.name_servers.1}",
    "${aws_route53_zone.k8s.name_servers.2}",
    "${aws_route53_zone.k8s.name_servers.3}"
  ]
}
```

Check if the zone has been configured correctly:
```
$ dig NS k8s.example.com
```
You should see the 4 NS records that Route53 assigned your hosted zone.


## Create an S3 bucket to store kops state

```
$ aws s3 mb s3://kops-state.example.com
$ export KOPS_STATE_STORE=s3://kops-state.example.com
```


## Create a cluster config

* Cluster name: `staging.k8s.example.com`

```
$ kops create cluster --ssh-public-key=/path/to/your-ssh-key.pub --zones=ap-northeast-1a,ap-northeast-1c staging.k8s.example.com
```

* Default nodes
    * master (`m3.medium`)
    * node (`t2.medium` * 2)
* Command options
    * https://github.com/kubernetes/kops/blob/master/docs/cli/kops_create_cluster.md


## Create a cluster with Terraform

[Building Kubernetes clusters with terraform](https://github.com/kubernetes/kops/blob/master/docs/terraform.md "kops/terraform.md at master · kubernetes/kops")

```
$ kops update cluster staging.k8s.example.com --target=terraform

$ cd out/terraform
$ terraform plan
$ terraform apply
```

Wait for the cluster to be launched and check:

```
$ kubectl cluster-info
Kubernetes master is running at https://api.staging.k8s.example.com
KubeDNS is running at https://api.staging.k8s.example.com/api/v1/proxy/namespaces/kube-system/services/kube-dns
```
