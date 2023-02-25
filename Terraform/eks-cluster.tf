
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"
   
  cluster_name = "my-cluster"
  cluster_version = "1.23"
  enable_irsa = true

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id
  
  depends_on = [
  ]

  tags = {
    environment = "development"
    application = "myapp"
  }

    eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t2.small"]
      
      #Additional policies required for ebs and autoscaling.
      iam_role_additional_policies = [
      "arn:aws:iam::793430165820:policy/AWS_CSI_DRIVER",
      "arn:aws:iam::793430165820:policy/node-group-autoscale-policy"
    ]
    }
  }

   fargate_profiles = {
    default = {
      name = "my-fargate-profile"
      selectors = [
        {
          namespace = "fpns"
          labels = {
          app = "java-mysql-app"
                   }
        }
      ]
    }
  }
}


data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"
  oidc_url = module.eks.cluster_oidc_issuer_url
}


module "cluster_autoscaler" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-cluster-autoscaler.git"

  enabled = true

  cluster_identity_oidc_issuer      = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn  = module.eks.oidc_provider_arn
  cluster_name                      = "my-cluster"
  aws_region                        = "eu-central-1"
}
