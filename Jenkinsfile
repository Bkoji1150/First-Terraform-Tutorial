pipeline {
  agent {
    kubernetes {
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
      defaultContainer 'shell'
    }

  }
  stages {
    stage('Create Workspace') {
      steps {
        container(name: 'kustomize') {
          sh """
                              set +e
                              kubectl create namespace $PROJECT-${env.BRANCH_NAME.toLowerCase()}
                              set -e
                              """
          sh 'curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip'
          sh ' unzip /tmp/terraform.zip'
          sh 'chmod +x terraform && mv terraform /usr/local/bin/'
          sh 'terraform -version'
        }

      }
    }

    stage('TFI') {
      steps {
        container(name: 'kustomize') {
          sh """
                                set +x
                               ssh 'terrafrom init'
                               sh "kubectl delete namespace  $PROJECT-${env.BRANCH_NAME.toLowerCase()}"
                               """
        }

      }
    }

  }
  environment {
    PROJECT = 'jenkins-demo'
    REGISTRY_USER = 'koji'
  }
  post {
    always {
      echo 'One way or another, I have finished'
      deleteDir()
    }

    success {
      echo 'I succeeded!'
      slackSend(color: 'good', message: 'build successful ${env.JOB_NAME} ${env.BUILD_NUMBER}, ', tokenCredentialId: 'SlackToken')
    }

    unstable {
      echo 'I am unstable :/'
    }

    failure {
      echo 'I failed :('
      slackSend(color: 'danger', message: "Build Started: ${env.JOB_NAME} ${env.BUILD_NUMBER}, FAILD", tokenCredentialId: 'SlackToken')
    }

    changed {
      echo 'Things were different before...'
    }

  }
}