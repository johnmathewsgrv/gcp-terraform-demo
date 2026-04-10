pipeline {
  agent any

  parameters {
    string(name: 'SNOW_TICKET', defaultValue: '', description: 'ServiceNow Ticket')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        echo "Triggered by ServiceNow Ticket: ${params.SNOW_TICKET}"
      }
    }

    stage('SAST Scan') {
      steps {
        sh '''
          /root/.local/bin/checkov -d . --quiet || true
        '''
      }
    }

    stage('Terraform Plan DEV') {
      steps {
        sh '''
          cd environments/dev
          terraform init
          terraform plan -var-file=terraform.tfvars
        '''
      }
    }

    stage('Deploy DEV') {
      steps {
        sh '''
          cd environments/dev
          terraform apply -var-file=terraform.tfvars -auto-approve
        '''
      }
    }

    stage('Approval to promote to TEST') {
      steps {
        input message: "Approve deployment to TEST?"
      }
    }

    stage('Terraform Plan TEST') {
      steps {
        sh '''
          cd environments/test
          terraform init
          terraform plan -var-file=terraform.tfvars
        '''
      }
    }

    stage('Deploy TEST') {
      steps {
        sh '''
          cd environments/test
          terraform apply -var-file=terraform.tfvars -auto-approve
        '''
      }
    }

    stage('Audit Log') {
      steps {
        sh '''
          echo "$(date): DEV and TEST deployed | Ticket: ${SNOW_TICKET}" >> audit.log
          cat audit.log
        '''
      }
    }
  }
}
