
aws eks --region eu-central-1 update-kubeconfig --name my-cluster
envsubst < app-values.yaml | helm install java-mysql-app java-mysql-app -f - -n fpns

open security group : dev-eks-node-group