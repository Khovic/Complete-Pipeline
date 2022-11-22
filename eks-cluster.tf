terraform {
  backend "s3" {
    bucket = "khovic-tf-project-bucket"
    key = "tf-project/state.tfstate"
    region = "eu-central-1"
    access_key = "<access-key>"
    secret_key = "<secret-key>"
  }
  
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name = "my-cluster"
  cluster_version = "1.23"

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

    eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.medium"]
    }
  }

   fargate_profiles = {
    default = {
      name = "my-fargate-profile"
      selectors = [
        {
          namespace = "fpns"
        }
      ]
    }
  }

}
