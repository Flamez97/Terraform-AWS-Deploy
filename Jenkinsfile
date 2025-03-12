pipeline {

  agent any

  environment {
    AWS_ACCESS_KEY = AWS_ACCESS_KEY
    AWS_SECRET_KEY = AWS_SECRET_KEY
  }

  stages {

    stage('TF Fmt') {
      steps {
        container('terraform') {
          sh 'terraform fmt'
          sh 'terraform init'
        }
      }      
    }

    stage('TF Plan') {
      steps {
        container('terraform') {
          sh 'terraform validate'
          sh 'terraform plan -out myplan'
        }
      }      
    }

    stage('TF Apply') {
      steps {
        container('terraform') {
          sh 'terraform apply -input=false myplan'
        }
      }
    }

  } 

}
