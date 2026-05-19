pipeline {
                git branch: 'main',
                url: 'https://github.com/satya66655/AWS-DOA.git'
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check'
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

                        input message: 'Approve Terraform APPLY?', ok: 'Apply'

                        sh 'terraform apply -auto-approve'
                    }

                    if (params.TF_ACTION == 'destroy') {

                        input message: 'Approve Terraform DESTROY?', ok: 'Destroy'

                        sh 'terraform destroy -auto-approve'
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

        always {
            cleanWs()
        }
    }
}
