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

        stage('Docker Image for Master'){
             when{
                branch 'master'
            }
            steps{
               echo 'Creation and Tagging of docker image for master branch'
               bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:${BUILD_NUMBER} -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:latest ."
            }
        }

        stage('Docker Image for Develop'){
            when{
                branch 'develop'
            }    
            steps{
                echo 'Creation and Tagging of docker image for develop branch'
                bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:${BUILD_NUMBER} -t ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:latest ."
            }
        }

        stage('Containers'){
           parallel{
               stage('PreContainerCheck'){
                   echo "container check in parallel"
               }
               stage('PublishToDockerHub'){
                   echo "Pushing docker image to Docker Hub"
                   withDockerRegistry([credentialsId: 'DockerHub', url: ""]){
                       if(env.BRANCH_NAME == 'develop'){
                           bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-develop:${BUILD_NUMBER}"
                       }else{
                           bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${USERNAME}-master:${BUILD_NUMBER}"
                       }
                   }
               }
           }
        }
    }
}