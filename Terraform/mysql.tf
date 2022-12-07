# This gives back object with certificate-authority among other attributes: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster#attributes-reference
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

# This gives us object with token: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth#attributes-reference  
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "mysql" {
  name       = "mysql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "9.4.1"
  timeout    = "420"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    "${file("mysql-helm-values.yaml")}"
  ]

  depends_on = [
    resource.aws_security_group_rule.mysql-rule-in ,
    resource.aws_security_group_rule.mysql-rule-out
  ]
}
