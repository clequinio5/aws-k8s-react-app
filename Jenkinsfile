pipeline {
    agent any
    environment {
        npm_config_cache = 'npm-cache'
    }
    stages {
        stage('Check') {
            steps {
                sh 'aws --version'
                sh 'docker --version'
                sh 'node --version'
                sh 'npm --version'
                sh 'ls'
            }
        }
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh 'CI=true npm test'
            }
        }
        stage('Release') {
            steps {
                sh 'npm run build'
            }
        }
        stage('Dockerize') {
            steps {
                sh 'docker build . -f infra/Dockerfile -t clequinio/aws-k8s-react-app'
            }
        }
        stage('Push Docker Image') {
            steps {
                withDockerRegistry([url: "", credentialsId: "docker-credentials"]) {
                    sh "docker push clequinio/aws-k8s-react-app"
                }
            }
        }
        stage('Deploying') {
            steps{
                echo 'Deploying to AWS...'
                withAWS(credentials: 'aws-credentials', region: 'eu-west-3') {
                    sh "aws eks --region eu-west-3 update-kubeconfig --name aws-k8s-react-app"
                    sh 'kubectl config use-context arn:aws:eks:us-east-1:507569708173:cluster/aws-k8s-react-app'
                    sh 'kubectl apply -f k8s-config.yml'
                    sh "kubectl get nodes"
                    sh "kubectl get deployment"
                    sh "kubectl get pod -o wide"
                    sh "kubectl get service/client"
                    sh "kubectl get service/server"
                }
            }
    }
    stage("Cleaning up") {
            steps{
                sh 'echo Cleaning up...'
                sh "docker system prune"
            }
    }
    }
}





