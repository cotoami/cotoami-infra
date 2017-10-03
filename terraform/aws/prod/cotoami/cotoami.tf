module "environment" {
  source = "../"
}

provider "aws" {
  region = "ap-northeast-1"
}


//
// Neo4j
//

resource "aws_ebs_volume" "neo4j" {
  availability_zone = "ap-northeast-1c"
  size = 200
  type = "gp2"
  tags {
    Name = "cotoami-prod-neo4j"
  }
}
