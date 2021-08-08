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
            script{
                if(env.BRANCH_NAME == 'master'){
                    echo 'Creation and Tagging of docker image for master branch'
                    bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:${BUILD_NUMBER} -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:latest ."
                }else{
                    echo 'Creation and Tagging of docker image for develop branch'
                    bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:${BUILD_NUMBER} -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:latest ."
                }
            }
          }
        }
        
        stage('Containers'){
           parallel{
               stage('PreContainerCheck'){
                   steps{
                     echo "container check "
                     script{
                         containerIdCheck = "${bat (script: "docker ps -a -q -f status=running -f name=c-${DOCKER_REPOSITORY_NAME}-${env.BRANCH_NAME}", returnStdout: true).trim().readLines.drop(1).join(" ")}"
                     }
                   }
               }
            //    stage('PublishToDockerHub'){
            //      steps{
            //        echo "Pushing docker image to Docker Hub"
            //        script{
            //         withDockerRegistry([credentialsId: 'DockerHub', url: ""]){
            //             if(env.BRANCH_NAME == 'develop'){
            //                 bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:${BUILD_NUMBER}"
            //                 bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:latest"
            //             }else{
            //                 bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:${BUILD_NUMBER}"
            //                 bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:latest"
            //             }
            //         }
            //        }
            //      }
            //    }
           }
        }

        // stage('Docker Deployment'){
        //     steps{
        //         script{
        //             if(env.BRANCH_NAME == 'develop'){
        //                 bat "docker run --name c-${USERNAME}-${env.BRANCH_NAME} -d -p ${DOCKER_DEVELOP_PORT}:${APP_PORT} ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}" 
        //             }else{
        //                 bat "docker run --name c-${USERNAME}-${env.BRANCH_NAME} -d -p ${DOCKER_MASTER_PORT}:${APP_PORT} ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-${env.BRANCH_NAME}" 
        //             }
        //         }
        //     }
        // }

        // stage('K8s Deployment'){
        //     steps{
        //         bat 'kubectl apply -f k8s/'
        //     }
        // }
    }
}