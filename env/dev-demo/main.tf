# eks

terraform {
  backend "remote" {
    organization = "11st" # org name from step 2.
    workspaces {
      name = "terraform-aws-eks" # name for your app's state.
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = "ap-northeast-2"
}

module "eks" {
  source = "../../modules/eks"

  region = "ap-northeast-2"
  city   = "SEOUL"
  stage  = "DEV"
  name   = "DEMO"
  suffix = "EKS"

  kubernetes_version = "1.16"

  vpc_id = "vpc-09f37431d9b6acffa"

  subnet_ids = [
    "subnet-0bd2463f1c3868108",
    "subnet-005634e5cc63d62e6",
  ]

  buckets = [
    "artifact",
  ]

  launch_efs_enable = true

  launch_configuration_enable = false
  launch_template_enable      = true

  associate_public_ip_address = true

  instance_type = "m4.large"

  mixed_instances = ["m5.large", "r5.large", "c5.large"]

  volume_size = "32"

  min = "1"
  max = "5"

  on_demand_base = "0"
  on_demand_rate = "0"

  key_name = "11st-ce-key-v1"

  allow_ip_address = [
    "10.10.11.0/24", # bastion
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SEOUL-DEV-DEMO-BASTION"
      username = "iam-role-bastion"
      group    = "system:masters"
    },
  ]

  map_users = [
    {
      user     = "user/demo-user"
      username = "demo-user"
      group    = "system:masters"
    },
    {
      user     = "user/tfuser-api"
      username = "tfuser-api"
      group    = "system:masters"
    },
  ]
}

data "aws_caller_identity" "current" {
}

output "config" {
  value = module.eks.config
}
