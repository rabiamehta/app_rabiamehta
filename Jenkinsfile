pipeline{
    agent any

    tools{
        maven 'Maven3'
    }

    environment{
        def mvn = tool 'Maven3'
        SONAR_PROJECT_NAME = 'sonar-rabiamehta'
	    SONAR_PROJECT_KEY = 'sonar-rabiamehta'
        USERNAME = 'rabiamehta'
        DOCKER_REPOSITORY_NAME = 'rabiamehta'
        DOCKER_MASTER_PORT = 7200
        DOCKER_DEVELOP_PORT = 7300
        APP_PORT = 8080
    }

    options{
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }

    stages{
        stage('Code Checkout'){
            steps{
                echo 'Code Checkout'
            }
        }

        stage('Build'){
            steps{
                echo 'Building Application'
                bat 'mvn clean install'
            }
        }

        stage('Unit Testing'){
            when{
                branch 'master'
            }
            steps{
                echo 'Running Application Test Cases'
                bat 'mvn test'
            }
        }

        stage('Sonar Analysis'){
            when{
                branch 'develop'
            }
            steps{
                echo 'Analyzing application code with Sonar'
                withSonarQubeEnv('SonarQubeScanner') {
                   bat "mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY} -D sonar.projectName=${SONAR_PROJECT_NAME} -D sonar.projectVersion=${BUILD_NUMBER}"
              }
            }
        }

        stage('Docker Image'){
          steps{
                    echo 'Creation and Tagging of docker image'
                    bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}:${BUILD_NUMBER} -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}:latest ."
            }
        }
        
        stage('Containers'){
           parallel{
               stage('PreContainerCheck'){
                   steps{
                     echo "Checking if port is already in use by the container !"
                     script{
                         containerIdCheck = "${bat (script: "docker ps -a -q -f status=running -f name=c-${DOCKER_REPOSITORY_NAME}-${env.BRANCH_NAME}", returnStdout: true).trim().readLines().drop(1).join(" ")}"
                         echo containerIdCheck
                         if(containerIdCheck != ''){
                            echo "Stopping and removing already running container !"
                            bat "docker stop c-${DOCKER_REPOSITORY_NAME}-${env.BRANCH_NAME}"
                            bat "docker rm c-${DOCKER_REPOSITORY_NAME}-${env.BRANCH_NAME}"
                         }else{
                             echo "No existing running container found !"
                         }
                     }
                   }
               }
               stage('PublishToDockerHub'){
                 steps{
                   echo "Pushing docker image to Docker Hub"
                   script{
                    withDockerRegistry([credentialsId: 'DockerHub', url: ""]){
                            bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}:${BUILD_NUMBER}"
                            bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}:latest"
                    }
                   }
                 }
               }
           }
        }

        stage('Docker Deployment'){
            steps{
                script{
                    if(env.BRANCH_NAME == 'develop'){
                        bat "docker run --name c-${USERNAME}-${env.BRANCH_NAME} -d -p ${DOCKER_DEVELOP_PORT}:${APP_PORT} ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}" 
                    }else{
                        bat "docker run --name c-${USERNAME}-${env.BRANCH_NAME} -d -p ${DOCKER_MASTER_PORT}:${APP_PORT} ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}" 
                    }
                }
            }
        }

        stage('K8s Deployment'){
            environment{
                DEPLOYMENT_NAME = 'nagp-welcome-devops-deployment'
                NS = 'kubernetes-cluster-rabiamehta'
            }
            steps{
                script{
                    deploymentStatus = "${bat (script: "kubectl get deploy -n ${NS}", returnStdout: true)}"
                    if(deploymentStatus.contains(DEPLOYMENT_NAME+'-'+env.BRANCH_NAME)){
                        bat "kubectl rollout restart deployment/${DEPLOYMENT_NAME}-${env.BRANCH_NAME} -n ${NS}"
                        bat "kubectl rollout status -w deployment/${DEPLOYMENT_NAME}-${env.BRANCH_NAME} -n ${NS}"
                    }else{
                        bat 'kubectl apply -f k8s/'
                        bat "kubectl wait --for=condition=available deployment/${DEPLOYMENT_NAME}-${env.BRANCH_NAME} -n ${NS}"
                    }       
                }
            }
        }
    }

    post { 
        always { 
            echo 'Pipeline exited successfuly !'
        }
    }
}