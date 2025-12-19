def deployWithAnsible(host, playbook, extraVars = "") {
    sh """
        mkdir -p ~/.ssh
        ssh-keyscan -H ${host} >> ~/.ssh/known_hosts
        ansible-playbook \
          --inventory ansible/hosts.ini \
          ansible/${playbook} \
          --extra-vars "${extraVars}"
    """
}

pipeline {
    agent any

    environment {
        CONTAINER_NAME = "ttl.sh/esauflores-devops-exam-js:2h"
        NODEJS_VERSION = "24"
        KUBERNETES_SERVER_URL = "https://kubernetes:6443"
    }

    
    tools {
        nodejs "24.11.1"
    }
  

    stages {
        stage('Test') {
            steps {
                sh '''
                npm ci
                node --test "tests/**/*.test.js"
                '''    
            }
        }

         stage('Build Docker Image') {
            steps {
                sh "docker build -t ${CONTAINER_NAME} ."
            }
        }
        stage('Push Docker Image') {
            steps {
                sh "docker push ${CONTAINER_NAME}"
            }
        }

        stage('Deploy Target') {
            steps {
                sshagent(['target-ssh-credentials']) {
                    deployWithAnsible(
                        'target',
                        'target.yml',
                        "NODE_VERSION=${env.NODEJS_VERSION}"
                    )
                }
            }
        }

        stage('Deploy Docker') {
            steps {
                sshagent(['docker-ssh-credentials']) {
                    deployWithAnsible(
                        'docker',
                        'docker.yml',
                        "CONTAINER_NAME=${env.CONTAINER_NAME}"
                    )
                }
            }
        }

        stage('Deploy Kubernetes') {
            steps {
                withKubeConfig(
                    credentialsId: 'k8s-jenkins-token',
                    serverUrl: KUBERNETES_SERVER_URL,
                ) {
                    sh "kubectl apply -f definition.yml"
                }
            }
        }

    }
}