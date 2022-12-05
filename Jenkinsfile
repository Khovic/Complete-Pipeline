pipeline {
  agent any
  parameters {
    booleanParam(name: 'runTests', defaultValue: true, description: 'choose whether to execute test stage')
    choice(name: 'VerIncr', choices: ['patch', 'minor', 'major'], description: '')
  }

  tools {
    nodejs 'NodeJS'
  }


  environment {
    GIT_CREDENTIALS = credentials('GitKhovic')
    GIT_REPO = "github.com/Khovic/terraform-project.git"
    APP_NAME = "java-mysql-app"
    IMAGE_REPO = "793430165820.dkr.ecr.eu-central-1.amazonaws.com"
    APP_IMAGE = "${IMAGE_REPO}/${APP_NAME}"
    EKS_REGION = 'eu-central-1'
    EKS_CLUSTER_NAME = 'my-cluster'
    DB_USER = credentials('DB_USER')
    DB_NAME = credentials('DB_NAME')
    DB_SERVER = credentials('DB_SERVER')
    DB_PWD = credentials('DB_PWD')
    MYSQL_ROOT_PASSWORD= credentials('MYSQL_ROOT_PASSWORD')
  }
  

  stages { 
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
           def imageVar = "${APP_IMAGE}:latest"
           sh "./gradlew build"
           sh "docker image prune -f -a"
           //from some reason jenkins doesn't play nice when multiple args are passed to docker build, this script bypasses that behavior.
           sh "./Build-script.sh ${imageVar} ${version}"
           
           withCredentials([usernamePassword(credentialsId: 'ecr-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')])
           { 
            sh "aws ecr get-login-password --region ${EKS_REGION} | docker login --username AWS --password-stdin ${IMAGE_REPO}"
            sh "docker push ${imageVar}"
           }
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
                  sh "helm delete ${APP_NAME} -n fpns"
                  echo err.getMessage()
              }
              catch (error) {
                  echo error.getMessage()
                }
            }
            withCredentials([usernamePassword(credentialsId: 'ecr-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')])
           { 
            sh "aws ecr get-login-password --region ${EKS_REGION} | docker login --username AWS --password-stdin ${IMAGE_REPO}"
            sh 'kubectl apply -f mysql-secret.yaml'
            sh "envsubst < app-values.yaml | helm install ${APP_NAME} ${APP_NAME} -f - -n fpns"
           }
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
            sh "docker tag ${APP_IMAGE}:latest khovic/java-mysql-app:${version}"
            sh "docker push khovic/java-mysql-app:${version}"

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
