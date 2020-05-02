#!/usr/bin/env groovy

pipeline {
    agent any
    

    options {
        ansiColor('xterm')
        timestamps()
    }
    
    parameters {
       choice(name: 'TerraformCommand', choices: ['validate','refresh','plan','apply','destroy'], description: 'Terraform Run Command')
    }
    

    environment {
            AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
            AWS_ACCESS_SECRET_KEY = credentials('aws_access_key')
            TERRAFORM_COMMAND = "${params.TerraformCommand}"
    }
  stages {
        
        stage('Install and initialize Terraform') {
            steps {
              script{
                    LOCAL_PATH = "${WORKSPACE}/bin"
                    sh """
                    mkdir -p ${LOCAL_PATH}
                    curl -fL -o ${LOCAL_PATH}/terraform.zip https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
                    cd ${LOCAL_PATH} && unzip -qq terraform.zip && chmod 775 terraform
                    """
                }
            }
        }

        stage('Run Terraform') {
            steps {
              script{
                def TERRAFORM_EXTRA_ARGS = ""
                if ("${TERRAFORM_COMMAND}" == 'apply' || "${TERRAFORM_COMMAND}" == 'destroy'){
                    TERRAFORM_EXTRA_ARGS +="-auto-approve"
                }
                  sh """
                    ./bin/terraform init
                    sudo ./bin/terraform ${TERRAFORM_COMMAND} -var="aws_access_key=${AWS_ACCESS_KEY_ID}" -var="aws_secret_key=${AWS_ACCESS_SECRET_KEY}" ${TERRAFORM_EXTRA_ARGS}
                """
              }
            }
        }
    }
    post { 
        always {
          cleanWs()
        }
    }
}