pipeline {
    agent any
    tools { 
        maven 'maven-3.9.6' 
    }
        environment {
        // Replace with the actual path to your JDK installation
        JAVA_HOME = '/usr/local/opt/openjdk@21'
        DOCKER_PATH = "/usr/local/bin/docker"
    }
    stages {
        stage('Checkout git') {
            steps {
               git branch: 'master', url: 'https://github.com/oshaye3/devsecops-project-first'
            }
        }

   stage('Pre-Build') {
            steps {
                sh 'export JAVA_HOME'
                sh 'echo $JAVA_HOME'
                sh 'javac -version'
            }
        }

    stage('Checkov Scan') {
            steps {
                    // Run Checkov against your IaC files terraform
                   sh 'checkov -d ./modules/backend'       
                  sh 'checkov --version'    
            }
        } 
    
        stage('Terraform Init and Apply') {
            steps {
                // Set AWS credentials as environment variables
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
                    // Navigate to the Terraform files directory
                    dir('modules/backend') {
                        // Initialize Terraform
                        sh 'terraform init'
                        // Format Terraform code
                        sh 'terraform fmt'
                        // Validate Terraform code
                        sh 'terraform validate'
                        // Plan Terraform deployment
                        sh 'terraform plan -out=tfplan'
                        // Apply Terraform deployment
                        sh 'terraform apply -auto-approve -input=false tfplan'
                    }
                }
            }
        }

        stage('OWASP Dependency Check') {
    steps {
        script {
    try {
        // Check if the OWASP Dependency-Check tool is installed via Jenkins Global Tool Configuration
        def owaspTool = tool name: 'OWASP-Dependency-Check', type: 'DependencyCheckInstallation'
        echo "Using OWASP Dependency-Check tool at ${owaspTool}"

        // Run the OWASP Dependency-Check using the configured tool in Jenkins
        dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'OWASP-Dependency-Check'
    } catch (Exception e) {
        echo "OWASP Dependency-Check tool not configured in Jenkins, using fallback."
        def dependencyCheckPath = '/usr/local/bin/dependency-check'
        if (fileExists(dependencyCheckPath)) {
            // Run the OWASP Dependency-Check with additional arguments
            sh "${dependencyCheckPath} --project 'devsecops-app' --scan './' --out . --format 'HTML' --format 'XML'"
        } else {
            error "OWASP Dependency-Check binary not found at ${dependencyCheckPath}"
        }
    }
 }

 }
        
    }


stage('Build & JUnit Test') {
            steps {
                // Run 'mvn verify' instead of 'mvn install' to include tests without installing the package
                // The 'verify' phase in Maven lifecycle ensures that unit tests are run and JaCoCo report is generated
                sh 'mvn clean verify'
            }
            post {
                success {
                    // Publish JUnit test results
                    junit 'target/surefire-reports/**/*.xml'
                    // Publish JaCoCo coverage report
                    jacoco(execPattern: 'target/jacoco.exec')
                }
            }
        }



        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    // Running SonarQube analysis
                    // No need to run 'mvn clean verify' again, just 'sonar:sonar' is sufficient
                    // The SonarQube scanner will pick up the JaCoCo report from the previous stage
                    sh "mvn sonar:sonar \
                        -Dsonar.projectKey=devsecops \
                        -Dsonar.projectName='devsecops' \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=sqp_9546ab703ac21465aefa703a6cc4f400b3a9a374"
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Docker  Build') {
            steps {
                    sh '${DOCKER_PATH} build -t moshaye/sprint-boot-app:v1.$BUILD_ID .'
                    sh '${DOCKER_PATH} image tag moshaye/sprint-boot-app:v1.$BUILD_ID moshaye/sprint-boot-app:latest'
            }
        }

        stage('Image Scan') {
            steps {
                // Disables secret scanning and sets the timeout to 30 minutes
                sh '/usr/local/bin/trivy image  --debug  --timeout 30m0s --scanners vuln --format template --template "@/usr/local/bin/html.tpl" -o report.html moshaye/sprint-boot-app:latest'
            }
        }

     
        stage('Upload Scan report to AWS S3') {
              steps {
                  sh 'aws s3 cp report.html s3://michael-devsecops'
              }
         }

        stage('Docker Push') {
            steps {
                withVault(
                    configuration: [
                        skipSslVerification: true, 
                        timeout: 60, 
                        vaultCredentialId: 'd1bb3fcc-691b-44e8-9b95-ee48b7dc1547', 
                        vaultUrl: 'http://127.0.0.1:8200',
                        engineVersion: 1
                    ], 
                    vaultSecrets: [
                        [
                            path: 'secrets/creds/docker', 
                            secretValues: [
                                [envVar: 'DOCKER_USERNAME', vaultKey: 'username'], 
                                [envVar: 'DOCKER_PASSWORD', vaultKey: 'password']
                            ]
                        ]
                    ]
                ) {
                    // Ensure the environment variables are referenced correctly
                    sh "${env.DOCKER_PATH} login -u ${env.DOCKER_USERNAME} -p ${env.DOCKER_PASSWORD}"
                    sh "${env.DOCKER_PATH} push moshaye/sprint-boot-app:v1.${BUILD_ID}"
                    sh "${env.DOCKER_PATH} push moshaye/sprint-boot-app:latest"
                    // Also ensure you are removing the correct images
                    sh "${env.DOCKER_PATH} rmi moshaye/sprint-boot-app:v1.${BUILD_ID}"
                    sh "${env.DOCKER_PATH} rmi moshaye/sprint-boot-app:latest"
                }
            }
        }
        stage('Deploy to k8s') {
            steps {
                script{
                    kubernetesDeploy configs: 'spring-boot-deployment.yaml', kubeconfigId: 'kube-jenkins'
                }
            }
        }
        
 
    }
    post{
        always{
            dependencyCheckPublisher pattern: '**/dependency-check-report.*'
            sendSlackNotifcation()
              
            }
        }
}

def sendSlackNotifcation()
{
    if ( currentBuild.currentResult == "SUCCESS" ) {
        buildSummary = "Job_name: ${env.JOB_NAME}\n Build_id: ${env.BUILD_ID} \n Status: *SUCCESS*\n Build_url: ${BUILD_URL}\n Job_url: ${JOB_URL} \n"
        slackSend( channel: "#devsecops", token: 'slack-token', color: 'good', message: "${buildSummary}")
    }
    else {
        buildSummary = "Job_name: ${env.JOB_NAME}\n Build_id: ${env.BUILD_ID} \n Status: *FAILURE*\n Build_url: ${BUILD_URL}\n Job_url: ${JOB_URL}\n  \n "
        slackSend( channel: "#devsecops", token: 'slack-token', color : "danger", message: "${buildSummary}")
    }
}

    
