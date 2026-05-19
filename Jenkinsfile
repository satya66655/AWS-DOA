pipeline {
    agent any

    parameters {
        choice(
            name: 'TF_ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform Action'
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

                    if (params.TF_ACTION == 'plan') {
                        sh 'terraform plan'
                    }

                    if (params.TF_ACTION == 'apply') {

                        input message: 'Approve APPLY?', ok: 'Apply'

                        sh 'terraform apply -auto-approve'
                    }

                    if (params.TF_ACTION == 'destroy') {

                        input message: 'Approve DESTROY?', ok: 'Destroy'

                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
