
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
}


data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_security_group_rule" "DNS_UDP" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}


module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"
  oidc_url = module.eks.cluster_oidc_issuer_url
}

resource "aws_security_group_rule" "mysql-rule-in" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "mysql-rule-out" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "app-rule-in" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "app-rule-out" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "app-nginx-rule-out" {
  type              = "egress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "app-nginx-rule-in" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}



output "dev-sg" {
  value = module.eks.cluster_primary_security_group_id  
}

output "dev-sg1" {
  value = module.eks.cluster_security_group_id  
}

output "dev-sg2" {
  value = module.eks.eks_managed_node_groups.dev.security_group_id
}