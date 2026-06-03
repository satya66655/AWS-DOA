pipeline {
    agent any
      environment {
    TF_VAR_github_token = credentials('github-token')
    }
  
    stages {
      stage('Terraform Plan') {
        steps {
          sh '''
            terraform plan \
              -var=aws_account_id=886436941748 \
              -var=demo_date=03-06-2026
          '''
        }
      }
      }
  environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }
    parameters {
        choice(
            name: 'TF_ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform Action'
        )
        string(
            name: 'AWS_ACCOUNT_ID',
            defaultValue: '886436941748',
            description: 'AWS Account ID'
        )
        string(
            name: 'DEMO_DATE',
            defaultValue: '',
            description: 'Demo date tag in dd-mm-yyyy format (leave blank to auto-generate)'
        )
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/satya66655/AWS-DOA.git'
            }
        }
        stage('Verify Tools') {
            steps {
                sh 'terraform version'
                sh 'aws --version'
                sh 'aws sts get-caller-identity'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Terraform Action') {
            steps {
                script {
                    def tfVars = "-var='aws_account_id=${params.AWS_ACCOUNT_ID}' -var='demo_date=${params.DEMO_DATE}'"

                    if (params.TF_ACTION == 'plan') {
                        sh "terraform plan ${tfVars}"
                    }
                    if (params.TF_ACTION == 'apply') {
                        input message: 'Approve APPLY?', ok: 'Apply'
                        sh "terraform apply -auto-approve ${tfVars}"
                    }
                    if (params.TF_ACTION == 'destroy') {
                        input message: 'Approve DESTROY?', ok: 'Destroy'
                        sh "terraform destroy -auto-approve ${tfVars}"
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Terraform pipeline completed successfully.'
        }
        failure {
            echo 'Terraform pipeline failed.'
        }
    }
}
