
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
      instance_types = ["t3.medium"]
      
    node_security_group_additional_rules = {

    https_ingress = {
      description              = "Allow APP"
      protocol                 = "-1"
      from_port                = 8080
      to_port                  = 8080
      type                     = "ingress"
      source_cluster_security_group = true
    }
  
    }
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

resource "aws_security_group_rule" "app-rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = module.myapp-vpc.private_subnets
  security_group_id = module.eks.cluster_primary_security_group_id
}