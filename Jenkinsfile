pipeline {
  agent any

  parameters {
    string(name: 'SNOW_TICKET', defaultValue: '', description: 'ServiceNow Ticket')
  }

  stages {

    stage('Checkout Source Code') {
      steps {
        checkout scm
        echo "Pipeline triggered by ServiceNow Ticket: ${params.SNOW_TICKET}"
      }
    }

    stage('Terraform Validate') {
      steps {
        sh '''
          cd environments/dev
          terraform init -input=false
          terraform validate
        '''
      }
    }

    stage('Security Scan (SAST - Checkov)') {
      steps {
        sh '''
          export PATH=$PATH:/var/jenkins_home/.local/bin
          checkov -d . || true
        '''
      }
    }

    stage('Terraform Plan - DEV') {
      steps {
        sh '''
          cd environments/dev
          terraform init -input=false
          terraform plan -var-file=terraform.tfvars
        '''
      }
    }

    stage('Deploy Infrastructure - DEV') {
      steps {
        sh '''
          cd environments/dev
          terraform apply -var-file=terraform.tfvars -auto-approve
        '''
      }
    }

    stage('Approval to Promote to TEST') {
      steps {
        input message: "Approve deployment to TEST environment?"
      }
    }

    stage('Terraform Plan - TEST') {
      steps {
        sh '''
          cd environments/test
          terraform init -input=false
          terraform plan -var-file=terraform.tfvars
        '''
      }
    }

    stage('Deploy Infrastructure - TEST') {
      steps {
        sh '''
          cd environments/test
          terraform apply -var-file=terraform.tfvars -auto-approve
        '''
      }
    }

    stage('Deployment Audit Log') {
      steps {
        sh '''
          echo "$(date): DEV and TEST deployed | Ticket: ${SNOW_TICKET}" >> audit.log
          cat audit.log
        '''
      }
    }

  }
}
