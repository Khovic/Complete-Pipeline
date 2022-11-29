
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name = "my-cluster"
  cluster_version = "1.23"

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
          labels = {
          app = "java-mysql-app"
                   }
        }
      ]
    }
  }
}

#Attaching policy required for AWS_CSI_DRIVER
resource "aws_iam_role_policy_attachment" "AWS_CSI_DRIVER" {
  policy_arn = "arn:aws:iam::793430165820:policy/AWS_CSI_DRIVER"
  role       = aws_iam_role.module.eks.dev.arn
}

resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"
  oidc_url = resource.aws_iam_openid_connect_provider.openid_connect.url
}
