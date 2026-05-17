pipeline {
    agent any

    triggers {
        githubPush()
    }

    options {
        timestamps()
    }

    environment {
        IMAGE_NAME = 'devops-app'
        CONTAINER_NAME = 'devops-app'
        APP_PORT = '5000'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AskariSyed/devops-lab-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:5000 ${IMAGE_NAME}:latest
                '''
            }
        }
    }

    post {
        failure {
            sh 'docker logs ${CONTAINER_NAME} || true'
        }
    }
}