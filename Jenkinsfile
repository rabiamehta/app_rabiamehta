pipeline { 
    agent any
        
    tools {
        maven 'Maven'
    }
    environment {
	    def mvn = tool 'Maven';
	    SONAR_PROJECT_NAME = 'sonar-rabiamehta';
	    SONAR_PROJECT_KEY = 'sonar-rabiamehta';
	    DOCKER_REPOSITORY_NAME = 'rabiamehta';
    }
    
    options {
        timestamps()
    }
    
    stages {
     stage('Code Checkout') {
        steps {
		    echo "Code checkout"
         }
      }
        
     stage('Code Build') {
       steps {
                echo "Building Application"
                bat 'mvn clean install'
            }
        }
        
	 stage('Unit Test Cases') {
            steps {
                echo "Running Application Test Cases"
                bat 'mvn test'
            }
        } 
        
     stage("Code Analysis") {
         steps {
           echo "Analyzing application code with Sonar"
              withSonarQubeEnv('SonarQubeScanner') {
                bat "mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY} -D sonar.projectName=${SONAR_PROJECT_NAME} -D sonar.projectVersion=${BUILD_NUMBER}"
              }
         }
     }  
                    
     stage("Create Docker Image"){
        steps{
           echo "Containerizing the application with docker"
                 bat "docker build -t ${DOCKER_REPOSITORY_NAME}/i-${DOCKER_REPOSITORY_NAME}-master:${BUILD_NUMBER} ."
	         }
	     }
	 
	
	 stage("Push image to DCR"){
	    steps{
	       echo "Pushing docker image to Docker Hub"
		       withDockerRegistry([credentialsId: 'DockerHub', url:""]){
			   bat "docker push ${DOCKER_REPOSITORY_NAME}/i-${DOCKER_REPOSITORY_NAME}-master:${BUILD_NUMBER}"
		     }
		 }
	  }
	
	 stage ("Application Deployment"){
	   steps {
	     echo "Starting with Application Deployment"
               bat """
			"docker ps -aqf name= c-${DOCKER_REPOSITORY_NAME}-master ">tmp.txt
			set /p comd1=<tmp.txt
			if[%comd1%]==[](echo "no running container")
			else(
			docker stop %comd1%
			docker rm -f %comd1%
			)
        	"""
	      script{
	         bat "docker run --name c-${DOCKER_REPOSITORY_NAME}-master -d -p 7100:8080 ${DOCKER_REPOSITORY_NAME}/i-${DOCKER_REPOSITORY_NAME}-master:${BUILD_NUMBER}"
		     }
		 }
	 }
	
	 stage ("Success"){
	      steps{
		    echo "The pipeline completed successfully"
	       }
	    }
    }
}