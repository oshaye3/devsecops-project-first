pipeline {
    agent any
    tools { 
        maven 'maven-3.9.6' 
    }
        environment {
        // Replace with the actual path to your JDK installation
        JAVA_HOME = '/usr/local/opt/openjdk@21'
        DOCKER_PATH = "/usr/local/bin/docker"
        PATH = "/usr/local/bin:$PATH"
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
        
        stage ('Build & JUnit Test') {
            steps {
                sh 'mvn install' 
            }
            post {
               success {
                    junit 'target/surefire-reports/**/*.xml'
                }   
            }
        }
        stage('SonarQube Analysis'){
            steps{
                withSonarQubeEnv('sonarqube-server') {
                        sh "mvn clean verify sonar:sonar \
                           -Dsonar.projectKey=devsecops \
                           -Dsonar.projectName='devsecops' \
                           -Dsonar.host.url=http://localhost:9000 \
                           -Dsonar.token=sqp_9546ab703ac21465aefa703a6cc4f400b3a9a374"

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
      	            sh '/usr/local/bin/trivy image --format template --template "@/usr/local/share/trivy/templates/html.tpl" -o report.html moshaye/sprint-boot-app:latest'
            }
        }
        stage('Upload Scan report to AWS S3') {
              steps {
                  sh 'aws s3 cp report.html s3://michael-catalyst'
              }
         }
        stage('Docker  Push') {
            steps {
                withVault(configuration: [skipSslVerification: true, timeout: 60, vaultCredentialId: 'vault-cred', vaultUrl: 'http://your-vault-server-ip:8200'], vaultSecrets: [[path: 'secrets/creds/docker', secretValues: [[vaultKey: 'username'], [vaultKey: 'password']]]]) {
                    sh "docker login -u ${username} -p ${password} "
                    sh 'docker push moshaye/sprint-boot-app:v1.$BUILD_ID'
                    sh 'docker push moshaye/sprint-boot-app:latest'
                    sh 'docker rmi moshaye/sprint-boot-app:v1.$BUILD_ID moshaye/sprint-boot-app:latest'
                }
            }
        }
        stage('Deploy to k8s') {
            steps {
                script{
                    kubernetesDeploy configs: 'spring-boot-deployment.yaml', kubeconfigId: 'kubernetes'
                }
            }
        }
        
 
    }
    post{
        always{
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

    
