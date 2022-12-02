
Create node-group-autoscaler-policy on AWS webui and attach it to nodeGroupIAM Role 
create cluster-autoscaler-deployment.yaml and apply it
  [kubectl apply -f cluster-autoscaler-deployment.yaml]



Run pipeline

aws eks --region eu-central-1 update-kubeconfig --name my-cluster
envsubst < app-values.yaml | helm install java-mysql-app java-mysql-app -f - -n fpns

open security group : dev-eks-node-group