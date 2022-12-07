resource "aws_security_group_rule" "DNS_UDP" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
}

resource "aws_security_group_rule" "DNS_TCP" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.eks_managed_node_groups.dev.security_group_id
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
