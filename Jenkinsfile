pipeline {
    agent any
    environment {
        npm_config_cache = "npm-cache"
    }
    stages {
        stage("Check versions") {
            steps {
                sh '''
                    aws --version
                    eksctl version
                    kubectl version 2>&1 | tr -d '\n'
                    docker --version
                    node --version
                    npm --version
					hadolint --version
                    ls
                '''
            }
        }
        stage("Build") {
            steps {
                sh "npm install"
            }
        }
        stage("Test") {
            steps {
                sh "CI=true npm test"
            }
        }
        stage("Release") {
            steps {
                sh "npm run build"
            }
        }
        stage("Lint") {
            steps {
                sh "hadolint infra/Dockerfile"
            }
        }
        stage("Dockerize app") {
            steps {
                sh "docker build . -f infra/Dockerfile -t clequinio/aws-k8s-react-app:${env.BUILD_TAG}"
            }
        }
        stage("Push Docker Image") {
            steps {
                withDockerRegistry([url: "", credentialsId: "docker-credentials"]) {
                    sh "docker push clequinio/aws-k8s-react-app:${env.BUILD_TAG}"
                }
            }
        }
        stage("Create k8s aws cluster") {
            steps{
                sh "./infra/exist-aws-k8s-cluster.sh || ./infra/create-aws-k8s-cluster.sh || exit 0"
            }
        }
        stage("Map kubectl to the k8s aws cluster and configure") {
            steps{
                withAWS(credentials: "aws-credentials", region: "eu-west-3") {
                    sh "aws eks --region eu-west-3 update-kubeconfig --name aws-k8s-react-app"
                    sh "kubectl config use-context arn:aws:eks:eu-west-3:507569708173:cluster/aws-k8s-react-app"
                    sh "kubectl apply -f infra/k8s-config.yml"
                }
            }
        }
        stage("Deploy the new app dockerized") {
            steps{
                withAWS(credentials: "aws-credentials", region: "eu-west-3") {
                    sh "kubectl set image deployment/aws-k8s-react-app-deployment aws-k8s-react-app=clequinio/aws-k8s-react-app:${env.BUILD_TAG}"
                }
            }
        }
        stage("Test deployment") {
            steps{
                withAWS(credentials: "aws-credentials", region: "eu-west-3") {
                    sh "kubectl get nodes"
                    sh "kubectl get deployment"
                    sh "kubectl get pod -o wide"
                    sh "kubectl get service/service-aws-k8s-react-app"
                    sh "curl \$(kubectl get service/service-aws-k8s-react-app --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
                }
            }
        }
        stage("Remove all unused containers, networks, images") {
            steps{
                sh "docker system prune -f"
            }
        }
    }
}





