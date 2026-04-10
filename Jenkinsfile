pipeline {
  agent any

  parameters {
    choice(name: 'ENVIRONMENT', choices: ['dev', 'test'], description: 'Target environment')
    string(name: 'SNOW_TICKET', defaultValue: '', description: 'ServiceNow Ticket')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        echo "Triggered by ServiceNow: ${params.SNOW_TICKET}"
      }
    }

    stage('SAST Scan') {
      steps {
        sh '''
          pip3 install checkov --quiet
          checkov -d . --quiet || true
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh """
          cd environments/${params.ENVIRONMENT}
          terraform init
          terraform plan -var-file=terraform.tfvars
        """
      }
    }

    stage('Deploy') {
      steps {
        sh """
          cd environments/${params.ENVIRONMENT}
          terraform init
          terraform apply -var-file=terraform.tfvars -auto-approve
        """
      }
    }

    stage('Audit Log') {
      steps {
        sh """
          echo "\$(date): Deployed to ${params.ENVIRONMENT} | Ticket: ${params.SNOW_TICKET}" >> audit.log
          cat audit.log
        """
      }
    }
  }
}
