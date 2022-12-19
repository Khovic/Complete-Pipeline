# terraform-project

This project is an example of a complete CI\CD pipeline in jenkins, and demonstrates use of Jenkins, Terraform, Kubernetes, Docker, Git, AWS, Bash.
In summary: we want to run a JS web app that requires MYSQL, the pipeline will automatically set up all the neccessary infrastructure for running our app,
reduce uneccessary costs while keeping our app highly available with minimum downtimes.

Once set up, the pipeline will apply provision infrastracture for our EKS cluster, the cluster consists of:
 - Cluster autoscaler for cost efficiency. 
 - 1-3 EC2 instances for running the application (based on load).
 - Nginx controller and ingress for web access to our app. 
 - Create VPC for our cluster.
 - Create necessary security group rules.
 - Attach policies (as found in Kubernetes/AWS-Policies/) to the cluster autoscaler and CSI driver.

Afterwards, The pipeline will perform the following
 - Run MYSQL stateful set with 1 primary and 2 secondary pods, as well it will provision GP2 storage for our MYSQL database.
 - Automatically increment version of our app.
 - Build the app and create a docker image for further deployment of our app, then push it to a private ECR.
 - Deploy the app to our cluster in a 3 pod replicaset for high availability, using our own helm chart (java-mysql-app as found in Kubernetes/).
 - If deployment successful it will push the dockerized app to a public DockerHub repository.
 - Update github /app/build.gradle with the latest app version.
 
 
 
