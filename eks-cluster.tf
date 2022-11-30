
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
    
    node_security_group_additional_rules = {

    https_ingress = {
      description              = "Allow HTTPS"
      protocol                 = "-1"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_cluster_security_group = true
    }
  

}

/*
resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}*/

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"
  #oidc_url = resource.aws_iam_openid_connect_provider.openid_connect.url
  oidc_url = module.eks.cluster_oidc_issuer_url
}

/*
module "eks-cluster-autoscaler" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "2.0.0"
#   insert the 3 required variables here
  cluster_identity_oidc_issuer = module.eks.my-cluster.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn =  module.eks.my-cluster.oidc_provider_arn
  cluster_name = "my-cluster"
}
*/