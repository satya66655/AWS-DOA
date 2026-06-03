#!/usr/bin/env groovy

// ════════════════════════════════════════════════════════════════════════════
// Jenkinsfile for AWS DevOps Agent Demo - CodePipeline Terraform Deployment
// GitHub token is securely managed via Jenkins credentials
// ════════════════════════════════════════════════════════════════════════════

pipeline {
  agent any

  // ════════════════════════════════════════════════════════════════════════
  // Environment variables - GitHub token loaded from Jenkins credentials
  // ════════════════════════════════════════════════════════════════════════
  environment {
    AWS_REGION         = 'us-east-1'
    TF_INPUT           = 'false'
    TF_IN_AUTOMATION   = 'true'
    TF_VAR_github_token = credentials('GithubToken')  // ✅ Secure credential
  }

  // ════════════════════════════════════════════════════════════════════════
  // Parameters for Jenkins UI
  // ════════════════════════════════════════════════════════════════════════
  parameters {
    choice(
      name: 'ACTION',
      choices: ['Plan', 'Apply', 'Destroy'],
      description: 'Terraform action to perform'
    )
    string(
      name: 'AWS_ACCOUNT_ID',
      defaultValue: '886436941748',
      description: 'AWS Account ID'
    )
    string(
      name: 'DEMO_DATE',
      defaultValue: '03-06-2026',
      description: 'Demo date (DD-MM-YYYY)'
    )
  }

  // ════════════════════════════════════════════════════════════════════════
  // Pipeline Stages
  // ════════════════════════════════════════════════════════════════════════
  stages {

    // ────────────────────────────────────────────────────────────────────
    // Stage 1: Checkout Code from Git
    // ────────────────────────────────────────────────────────────────────
    stage('Checkout Code') {
      steps {
        script {
          echo "🔍 Checking out AWS-DOA repository..."
        }
        git(
          url: 'https://github.com/satya66655/AWS-DOA.git',
          branch: 'main',
          credentialsId: ''
        )
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 2: Verify Tools
    // ────────────────────────────────────────────────────────────────────
    stage('Verify Tools') {
      steps {
        script {
          echo "✓ Verifying Terraform installation..."
          sh 'terraform version'
          
          echo "✓ Verifying AWS CLI installation..."
          sh 'aws --version'
          
          echo "✓ Verifying AWS credentials..."
          sh 'aws sts get-caller-identity'
        }
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 3: Terraform Init
    // ────────────────────────────────────────────────────────────────────
    stage('Terraform Init') {
      steps {
        script {
          echo "📦 Initializing Terraform..."
          sh 'terraform init'
        }
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 4: Terraform Validate
    // ────────────────────────────────────────────────────────────────────
    stage('Terraform Validate') {
      steps {
        script {
          echo "✓ Validating Terraform configuration..."
          sh 'terraform validate'
        }
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 5: Terraform Format Check (Optional)
    // ────────────────────────────────────────────────────────────────────
    stage('Terraform Format Check') {
      steps {
        script {
          echo "✓ Checking Terraform formatting..."
          sh 'terraform fmt -check -recursive'
        }
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 6: Terraform Plan / Apply / Destroy
    // ────────────────────────────────────────────────────────────────────
    stage('Terraform Action') {
      steps {
        script {
          echo "🚀 Running Terraform ${params.ACTION}..."
          
          def action = params.ACTION.toLowerCase()
          
          if (action == 'plan') {
            sh """
              echo "📋 Planning Terraform changes..."
              terraform plan \
                -var="aws_account_id=${params.AWS_ACCOUNT_ID}" \
                -var="demo_date=${params.DEMO_DATE}" \
                -out=tfplan
              echo "✓ Plan complete - review above"
            """
          }
          else if (action == 'apply') {
            sh """
              echo "⚙️  Applying Terraform changes..."
              terraform apply \
                -var="aws_account_id=${params.AWS_ACCOUNT_ID}" \
                -var="demo_date=${params.DEMO_DATE}" \
                -auto-approve
              echo "✓ Infrastructure deployed successfully!"
            """
          }
          else if (action == 'destroy') {
            input 'Are you sure you want to DESTROY all infrastructure? (Type "yes" to confirm)'
            sh """
              echo "🗑️  Destroying infrastructure..."
              terraform destroy \
                -var="aws_account_id=${params.AWS_ACCOUNT_ID}" \
                -var="demo_date=${params.DEMO_DATE}" \
                -auto-approve
              echo "✓ Infrastructure destroyed"
            """
          }
        }
      }
    }

    // ────────────────────────────────────────────────────────────────────
    // Stage 7: Output Terraform Outputs
    // ────────────────────────────────────────────────────────────────────
    stage('Display Outputs') {
      steps {
        script {
          echo "📊 Terraform Outputs:"
          sh 'terraform output -no-color 2>/dev/null || echo "No outputs available yet"'
        }
      }
    }

  } // end stages

  // ════════════════════════════════════════════════════════════════════════
  // Post Actions
  // ════════════════════════════════════════════════════════════════════════
  post {
    success {
      echo "✅ Pipeline completed successfully!"
    }
    failure {
      echo "❌ Pipeline failed. Check logs above for details."
    }
    always {
      // Clean up any sensitive files
      script {
        sh 'rm -f tfplan *.tfplan 2>/dev/null || true'
      }
    }
  }

}
