// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        kubernetes {
            // Rather than inline YAML, in a multibranch Pipeline you could use: yamlFile 'jenkins-pod.yaml'
            // Or, to avoid YAML:
            // containerTemplate {
            //     name 'shell'
            //     image 'ubuntu'
            //     command 'sleep'
            //     args 'infinity'
            // }
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: alpine
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - cat
    tty: true
    // volumeMounts:
    // - name: kaniko-secret
    //   mountPath: /kaniko/.docker/
  - name: kustomize
    image: nekottyo/kustomize-kubeval
    command:
    - cat
    tty: true
    volumes:
    - name: kaniko-secret
'''
            // Can also wrap individual steps:
            // container('shell') {
            //     sh 'hostname'
            // }
            defaultContainer 'shell'
        }
    }
    environment {
        PROJECT = "jenkins-demo"
        REGISTRY_USER = "koji"
    }
    stages {
        stage('Create Workspace') {
            steps {
                container("kustomize") {
                    sh """
                    set +e
                    kubectl create namespace $PROJECT-${env.BRANCH_NAME.toLowerCase()}
                    set -e
                    """
                    sh "curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip"
                    sh " unzip /tmp/terraform.zip"
                    sh "chmod +x terraform && mv terraform /usr/local/bin/"
                    sh "terraform -version && terrafrom init"
                    sh "kubectl delete namespace  $PROJECT-${env.BRANCH_NAME.toLowerCase()}"
                  }
            }
        }
        stage('TFI') {
        steps {
                container("kustomize") {
                    // withCredentials(roleArn: 'AWS_CRED_PROD', variable: 'aws') {
                     sh /* WRONG! */ """
                      set +x
                     echo "done"
                     sh  "apt-get install -y jq gzip nano tar git unzip wget"
                     """
                    }
                }
         }
        }
post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeded!'
            slackSend color: 'good', message: 'build successful ${env.JOB_NAME} ${env.BUILD_NUMBER}, ', tokenCredentialId: 'SlackToken'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
            slackSend color: 'danger', message: "Build Started: ${env.JOB_NAME} ${env.BUILD_NUMBER}, FAILD", tokenCredentialId: 'SlackToken'
        }
        changed {
            echo 'Things were different before...'
        }
    }
}
