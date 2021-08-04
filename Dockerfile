FROM openjdk:11.0.9.1-jre-buster
EXPOSE 8080
ADD target/welcomeDevOps-1.0.jar rabiaWelcomeApp.jar
ENTRYPOINT ["java","-jar","/rabiaWelcomeApp.jar"]