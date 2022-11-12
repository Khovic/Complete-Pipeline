first deploy cluster via eksctl
  [eksctl create cluster -f eksctl-cluster.yaml]

create cluster-autoscaler-deployment.yaml and apply it
  [kubectl apply -f cluster-autoscaler-deployment.yaml]

Create node-group-autoscaler-policy on AWS webui and attach it to nodeGroupIAM Role 

create mysql-secret.yaml and apply it  
  [kubectl apply -f mysql-secret.yaml]

create AWS CSI driver policy in IAM. 
add the policy and its permissions to the EC2 instance.
deploy AWS CSI driver to cluster:
  [kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.12"]
  
create additional storageclass "gp2.yaml" file and  apply it  
  [kubectl apply -f gp2.yaml]

make sure DB_* and MYSQL_ROOT_PASSWORD env vars are set.
create mysql-helm-values.yaml, and apply it
  [envsubst < mysql-helm-values.yaml| helm install mysql bitnami/mysql  --values -]

create phpmyadmin-deployment.yaml and apply it
  [kubectl apply -f phpmyadmin-deployment.yaml]

---------------OFFICIAL INSTALLATION STEPS FOR NGINX INGRESS------------
Add the following Helm ingress-nginx repository to your Helm repos.
 helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Update your Helm repositories.
 helm repo update

Install the NGINX Ingress Controller. This installation will result in a Linode NodeBalancer being created.
 helm install ingress-nginx ingress-nginx/ingress-nginx
-----------------------------------------------------------------------------

Run pipeline
