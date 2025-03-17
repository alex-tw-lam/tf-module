pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Get Parameters') {
            steps {
                script {
                    echo 'DEBUG: Reading schema and default values files'
                    def schema = readFile 'schema.json'
                    def defaultVals = readFile 'terraform.tfvars.json'
                    echo "DEBUG: Default values content: ${defaultVals}"

                    def tfvars = input message: 'Configure Terraform Variables', parameters: [
                        jsonEditor(
                            name: 'tfvars',
                            schema: schema,
                            startval: defaultVals
                        )
                    ]

                    echo "DEBUG: Received tfvars input: ${tfvars}"
                    echo "DEBUG: tfvars type: ${tfvars.getClass()}"

                    // Convert the JSON object to a properly formatted JSON string
                    def jsonString = groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(tfvars))
                    echo "DEBUG: Formatted JSON string: ${jsonString}"

                    // Write parameters to tfvars file
                    writeFile file: 'terraform.tfvars.json', text: jsonString
                    echo 'DEBUG: File written, checking content:'
                    sh 'cat terraform.tfvars.json'

                    stash includes: 'terraform.tfvars.json', name: 'tfvars'
                    echo 'DEBUG: File stashed'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh '''
                        terraform version
                        terraform init -input=false -no-color
                    '''
                }
            }
        }

        stage('Terraform Format') {
            steps {
                script {
                    sh 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    echo 'DEBUG: Before unstash - checking if file exists:'
                    sh 'ls -la || true'

                    unstash 'tfvars'
                    echo 'DEBUG: After unstash - file content:'
                    sh 'cat terraform.tfvars.json || true'

                    // First run plan and save it to file
                    sh '''
                        terraform plan \
                            -input=false \
                            -no-color \
                            -var-file="terraform.tfvars.json" \
                            -out=tfplan
                    '''

                    // Then run plan with detailed exit code to check for changes
                    def exitCode = sh(
                        script: '''
                            terraform show -no-color tfplan | \
                            terraform plan \
                                -input=false \
                                -no-color \
                                -detailed-exitcode \
                                -var-file="terraform.tfvars.json"
                        ''',
                        returnStatus: true
                    )

                    echo "Plan exit code: ${exitCode}"

                    if (exitCode == 0) {
                        echo 'No changes detected in Terraform plan'
                        currentBuild.result = 'SUCCESS'
                        return
                    } else if (exitCode == 1) {
                        error 'Terraform plan failed'
                    }
                    // exitCode == 2 means changes present, continue pipeline
                }
            }
        }

        stage('Approval') {
            when {
                branch 'main'  // Only run approval on main branch
            }
            steps {
                script {
                    // Show tfvars diff
                    def tfvarsDiff = sh(
                        script: 'git diff terraform.tfvars.json || true',
                        returnStdout: true
                    ).trim()

                    echo 'Terraform Variables Changes:'
                    echo "${tfvarsDiff}"

                    input message: '''Review the changes:

Terraform Variables Diff:
${tfvarsDiff}

Do you want to apply these changes?'''
                }
            }
        }

        stage('Commit Changes') {
            when {
                branch 'main'  // Only commit on main branch
            }
            steps {
                script {
                    // Configure Git
                    sh '''
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins Pipeline"
                    '''

                    // Add and commit tfvars changes
                    sh '''
                        git add terraform.tfvars.json
                        git commit -m "Update terraform.tfvars.json via Jenkins Pipeline [skip ci]" || true
                        git push origin HEAD:main
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'  // Only apply on main branch
            }
            steps {
                script {
                    sh '''
                        terraform apply \
                            -input=false \
                            -no-color \
                            tfplan
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
