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
                    // Run Checkov against your IaC files
                  //  sh 'checkov -d . --skip-check * --quiet'       
                  sh 'checkov --version'    
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

        //         stage('OWASP Dependency Check') {
        //     steps {
        //                       // Running OWASP Dependency-Check
        //           sh  "dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'default'"
                
        //     }
        // }
        stage('Upload Scan report to AWS S3') {
              steps {
                  sh 'aws s3 cp report.html s3://michael-catalyst'
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

    
