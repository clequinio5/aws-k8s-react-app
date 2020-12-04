pipeline {
    agent any
    environment {
        npm_config_cache = 'npm-cache'
    }
    stages {
        stage('Check') {
            steps {
                sh 'aws --version'
                sh 'eksctl version'
                sh 'kubectl version 2>&1 | tr -d "\n"'
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
                    sh './infra/exist-aws-k8s-cluster.sh || ./infra/create-aws-k8s-cluster.sh || exit 0'
                    sh "aws eks --region eu-west-3 update-kubeconfig --name aws-k8s-react-app"
                    sh 'kubectl config use-context arn:aws:eks:eu-west-3:507569708173:cluster/aws-k8s-react-app'
                    //sh 'kubectl apply -f infra/aws-auth-cm.yml'
                    sh 'kubectl apply -f infra/k8s-config.yml'
                    sh "kubectl set image deployment/aws-k8s-react-app-deployment aws-k8s-react-app=clequinio/aws-k8s-react-app:latest"
                    sh "kubectl get nodes"
                    sh "kubectl get deployment"
                    sh "kubectl get pod -o wide"
                    sh "kubectl get service/service-aws-k8s-react-app"
                }
            }
    }
    stage("Remove all unused containers, networks, images") {
            steps{
                echo 'Cleaning up...'
                sh "docker system prune -f"
            }
    }
    }
}





