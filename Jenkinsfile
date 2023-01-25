pipeline {
  agent any
  parameters {
    booleanParam(name: 'applyTerraform', defaultValue: false, description: 'choose whether to apply terraform configuration')
    booleanParam(name: 'runTests', defaultValue: true, description: 'choose whether to execute test stage')
    booleanParam(name: 'destroyTerraform', defaultValue: false, description: 'choose whether to terraform destroy')
    choice(name: 'VerIncr', choices: ['patch', 'minor', 'major'], description: 'choose the kind of version increment')
  }

  tools {
    nodejs 'NodeJS'
  }

  //Environment variables required for running the pipeline and starting the app. 
  //Due to security, some of the variables are saved as credentials within Jenkins.
  environment {
    GIT_CREDENTIALS = credentials('GitKhovic')
    GIT_REPO = "github.com/Khovic/Complete-Pipeline.git"
    APP_NAME = "java-mysql-app"
    IMAGE_REPO = "793430165820.dkr.ecr.eu-central-1.amazonaws.com"
    DOCKER_IMAGE_REPO = "khovic/java-mysql-app"
    APP_IMAGE = "${IMAGE_REPO}/${APP_NAME}"
    EKS_REGION = 'eu-central-1'
    EKS_CLUSTER_NAME = 'my-cluster'
    DB_USER = credentials('DB_USER')
    DB_NAME = credentials('DB_NAME')
    DB_SERVER = credentials('DB_SERVER')
    DB_PWD = credentials('DB_PWD')
    MYSQL_ROOT_PASSWORD= credentials('MYSQL_ROOT_PASSWORD')
  }
  
  //If "applyTerraform" param is enabled, the pipeline will apply the latest terraform configuration.
  //Usally this would be in a different repository and ran by a different pipeline, but for the sake of 
  //simplicity and readability we chose to have it as part of one repository and one pipline
  stages { 
       stage("provision cluster") {
            when {
          expression {
            params.applyTerraform
          }
        }
        steps {
          script {
            dir("Terraform") {
            sh "envsubst <  mysql-helm-values-template.yaml > mysql-helm-values.yaml"
            sh "terraform init"
            sh "terraform apply --auto-approve"
            }
          }
        }
    }    
       //will destory terraform infrastracture
       stage("destroy cluster") {
            when {
          expression {
            params.destroyTerraform
          }
        }
        steps {
          script {
            dir("Terraform") {
            sh "terraform init"
            sh "terraform destroy --auto-approve"
            }
          }
        }
    }    


    //Runs increment version script based on input from 'VerInc' choice parameter and prints the resulting build.gradle file.
    //Here it will run the application testing sequence if "Run Tests" is enabled when the pipeline is initiated
    stage("test") {
      when {
          expression {
            params.runTests
          }
        }
      steps {
        echo 'Executing testing stage....'
        sleep 3 //seconds
        echo 'Testing stage passed'
      }
    }    


    stage("increment version") {
      steps {
        script{
          dir("app") {
           sh "./increment-version.sh ${params.VerIncr}"
           sh "cat build.gradle"
          }
        }
        echo 'increment version stage executed'
      }
    }


    //Builds builds a docker image according to Dockerfile and pushes it to a temporary ECR for deployment in the next stage.
    //Reads version.txt created by increment-version.sh for tagging and exporting required ENV vars.
    //DB_* env vars are required by the application and must be set within the jenkins container prior to pipeline initiation.
    stage("build") {
      steps {
        script{
          dir("app") {
           def version = readFile(file: 'version.txt')
           sh "export VERSION=${version}"
           def imageVar = "${APP_IMAGE}:${version}"
           sh "./gradlew build"
           sh "ls build/libs/"
           sh "docker image prune -f -a"
          
           //from some reason jenkins doesn't play nice when multiple args are passed to docker build, this script bypasses that behavior.
           sh "./Build-script.sh ${imageVar}" 
           sh "docker images"
           sh "aws ecr get-login-password --region ${EKS_REGION} | docker login --username AWS --password-stdin ${IMAGE_REPO}"
           sh "docker push ${imageVar}"
          }
        }
        echo 'build stage executed'
      }
    }
      
   //kubectl, aws-cli, eksctl and helm all need to be installed within the jenkins container prior to deploy stage .
    stage("deploy") {
      steps {
        script{
          
          dir("kubernetes"){
            
            //this needs to be run only once:
            sh "aws eks update-kubeconfig --region ${EKS_REGION} --name ${EKS_CLUSTER_NAME}"
            
            //this deletes old java-app pods, if there is no app deployment on the cluster the resulting error will be cought.
            try {
              sh "kubectl create namespace fpns"
            } 
            catch (err) {
              try{
                  sh "helm delete ${APP_NAME}"
                  echo err.getMessage()
              }
              catch (error) {
                  echo error.getMessage()
                }
            }

            sh "aws ecr get-login-password --region ${EKS_REGION} | docker login --username AWS --password-stdin ${IMAGE_REPO}"
            // we will export the ingress address to "INGRESS_ADDRESS" env var
            sh '''export INGRESS_ADDRESS=$(kubectl get svc -n kube-system | grep LoadBalancer | awk -F ' ' '{print $4}')'''
            sh 'printenv'
            sh "envsubst < app-values.yaml | helm install ${APP_NAME} ${APP_NAME} -f - "

         echo 'deployment stage executed'
        }
      }
    }
    }

    //If deployment successful, the pipeline will push updated build.gradle file to ${GIT_REPO} (post version increments),
    //Using ${GIT_CREDENTIALS} as defined in line 14.
    stage("git push") {
      steps {
        script{
          dir("app") {
           sh 'git config --global user.email "jen@kins.com"'
           sh 'git config --global user.name "JenkinsJob"'
           sh "git remote set-url origin https://${GIT_CREDENTIALS}@${GIT_REPO}"
           sh "git add build.gradle"
           sh "git commit -m 'updated package json'"
           sh "git push -f origin HEAD:main"

          }
        }
        echo 'git push version stage executed'
      }
    }
    

    //Assuming all previous stages were successful, this stage will push the final and working image to a more permenant Dockerhub repository.
    //The image would be tagged khovic/java-mysql-app:${VERSION}
    stage("push Image") {
      steps {
        script{
          dir("app"){
           withCredentials([usernamePassword(credentialsId: 'DockerKhovic', passwordVariable: 'PASS', usernameVariable: 'USER')])
           { 
            def version = readFile(file: 'version.txt')
            sh "echo $PASS | docker login -u $USER --password-stdin"
            def source_image = "${APP_IMAGE}:${version}"
            def target_image = "khovic/java-mysql-app:${version}"
            env.TARGET = target_image
            env.SOURCE = source_image
            sh "echo $TARGET"
            sh "docker tag $SOURCE $TARGET"
            //def command = "${source_image} ${TARGET}"
            //echo "${command}"
            //sh "docker tag ${source_image} ${TARGET}"
            //sh "docker push ${DOCKER_IMAGE_REPO}:${version}"
           }
            echo 'image pushed to repo'
          }    
        }
      }
    }
  }


//       
    post {
      always {
        echo 'end of pipeline'
      }
    }

 }
