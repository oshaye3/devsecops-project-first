# DevSecOps-Project

In this project, I created an end-to-end CI/CD pipeline while keeping in mind Securities Best Practices, DevSecOps principles and used all these tools *Git, GitHub, Terraform, Checkov, OWASP, Jenkins,Maven, Junit, SonarQube, Docker, Trivy, AWS S3, Docker Hub, Kubernetes , Slack, Prometheus, Grafana and Hashicorp Vault,*  to achive the goal.


## Project Architecture application deployment
![](https://github.com/oshaye3/Devsecops-project-first/blob/master/Images/architecture.png)

## Project Infra Architecture option 1 ( Using the github action with TF to deploy the s3 bucket) 
![](https://github.com/oshaye3/Devsecops-project-first/blob/master/Images/option1-infra.png)

## Project infra Architecture option 2 ( This is selected and used directly in the CICD pipeline)
![](https://github.com/oshaye3/Devsecops-project-first/blob/master/Images/option2-infra.png)


## Pipeline flow only using the Project infra Architecture option 2 :
1. Source Code Retrieval: Jenkins checks out the source code from the specified GitHub repository to start the pipeline.

2. Pre-Build Setup: The pre-build stage sets up the necessary environment variables, ensuring the correct Java SDK and Docker paths are in place.

3. Infrastructure Code Analysis: Checkov performs static code analysis on the Terraform files within the backend modules to identify potential security issues.

4. Infrastructure Provisioning: Terraform initializes and applies infrastructure changes to AWS, using credentials securely provided, and ensures the code is formatted and validated.

5. Dependency Security Scan: The OWASP Dependency Check scans the project dependencies for security vulnerabilities, outputting reports in multiple formats.

6. Code Compilation and Unit Testing: Maven compiles the code and JUnit performs unit tests. Successful tests result in publishing the test reports and code coverage metrics.

7. Code Quality Analysis: SonarQube analyzes the codebase for quality issues. The results are measured against the configured quality gate criteria in SonarQube and made available on a dashboard.

8. Containerization: A Docker image is built from the source code, ready for deployment.

9. Security Scan of Container: The Docker image undergoes a vulnerability scan with Trivy, with the resulting report sent to an AWS S3 bucket for archival.

10. Image Repository Push: The Docker image is pushed to Docker Hub, with credentials securely retrieved from Vault.

11. Deployment to Kubernetes: The application is deployed to a Kubernetes cluster, completing the application's journey from code to deployment.

12. Throughout this pipeline, Jenkins is configured to collect metrics on build times, success rates, and other relevant data. These metrics are exposed to Prometheus, which continuously scrapes and stores them. Grafana, in turn, is set up to retrieve this data from Prometheus, providing real-time visualization of the Jenkins pipeline's performance and health. This allows teams to monitor the pipeline's efficiency and troubleshoot issues quickly, promoting a more reliable CI/CD process.

The integration with Prometheus and Grafana is typically achieved through Jenkins plugins and additional configuration in the Jenkins instance to expose the metrics. The detailed setup would involve:

Installing and configuring the Prometheus plugin in Jenkins.
Setting up a Prometheus server to scrape Jenkins metrics.
Configuring Grafana to connect to Prometheus as a data source.
Creating dashboards in Grafana to visualize the Jenkins pipeline metrics.
The integration adds an observability layer to the pipeline, ensuring that any deviations from expected performance can be detected and addressed promptly.

### stage view to illustrate the flow of pipeline that is successful
![](https://github.com/oshaye3/Devsecops-project-first/blob/master/Images/stage-view.png)

### PreRequisites
1. JDK 
1. Git 
1. Github
1. Checkov
1. Jenkins
1. Sonarqube
1. Jacoco
1. OWASP
1. Docker
1. Trivy
1. AWS account
1. Docker Hub account
1. Minikube & Kubectl
1. Hashicorp Vault
1. Slack
1. Grafana
1. Prometheus

 # Want to create this Project by your own  then *Follow these  project steps*
## Step: 1 Installation Part 

### Stage-01 : Install JDK and Create a Java Springboot application
Push all the web application page code file into github

![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/code.png) 

### Stage-02 : Install Jenkins and start Jenkins 
Jenkins Installation Prequuisities  https://www.jenkins.io/doc/book/installing/linux/
1. Installation guide is available here  https://github.com/oshaye3/devsecops-project-first/blob/main/Jenkins_installation.md
1. After installation, install suggested plugins
1. Open Jenkins Dashboard and install required plugins – SonarQube Scanner, Hashicorp Vault, Slack
1. go to manage jenkins > manage pulgins > search for plugins > install without restart
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/jenkins.png) 

1. We will required another pulgin called - Kubernetes Continuous Deploy Plugin ( this plugin is deprecated but we can down grade the version for just testing purpose)
Download the Plugin file from here https://github.com/oshaye3/devsecops-project-first/blob/main/kubernetes-cd.hpi
1. Now go to manage jenkins > manage pulgins > Advanced Setting > Deploy Plugin > choose the download file ( kubernetes-cd.hpi) > click on Deploy
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/plugins.png) 

### Stage-03 : Install Postgre Database and Install SonarQube
1. Installation guide is available here https://github.com/oshaye3/devsecops-project-first/blob/main/sonarqube_installation_with_postgres_database.md
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/sonarqube.jpeg) 
### Stage-04 : Install Docker and Create DockerHub account
1. Installation guide is available here https://github.com/oshaye3/devsecops-project-first/blob/main/docker_installation.md
1. Create DockerHub account 

![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/dockerhub.png) 


### Stage-05 : Install Trivy for Vulnerability Scanner for Containers and other Artifacts
I Used Mac

brew  install trivy
    
#### After trivy installation you can scan Container Images, FileSystem, Git Repositories
In our can we will scan contianer images

```sh 
   trivy image [YOUR_IMAGE_NAME]
   ``` 

### Stage-06 : Install Hashicorp Vault server 
HashiCorp Vault is a secret-management tool specifically designed to control access to sensitive credentials in a low-trust environment.
1. Installation guide is available here https://www.cyberithub.com/how-to-install-hashicorp-vault-on-ubuntu-20-04-lts/

### Stage-07 : Install Slack
Slack is a workplace communication tool, “a single place for messaging, tools and files.” .

Install Slack from official website of Slack https://slack.com/intl/en-in/downloads/ and choose Mac or Linux 


### Stage-08: Install Minikube
Minikube installation Guide is Available here  https://www.linuxtechi.com/how-to-install-minikube-on-ubuntu/  It is easy in Mac just used 
     brew install minikube

# Done with Installation , Now will we integrate all the tools with Jenkins

## Step: 2 Integeration Part

### Stage-01 : Hashicorp Vault integration with Jenkins
I am assuming that your Vault server is running 

Video guide to integrate Hashicorp Vault with Jnekins https://www.youtube.com/watch?v=5-RMu9M_Anc

##### 1. create Vault server App role and secret id 
* Copy the following to `/etc/vault.d/vault.hcl`
```
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "raft_node_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
```

* `sudo systemctl stop vault`
* `sudo systemctl start vault`

#### Commands to run to configure Vault and create AppRole

* `export VAULT_ADDR='http://127.0.0.1:8200'`
* `vault operator init`
* `vault operator unseal`
* `vault operator unseal`
* `vault operator unseal`
* `vault login <Initial_Root_Token>`
   * `<Initial_Root_Token>` is found in the output of `vault operator init`
* `vault auth enable approle`
* `vault auth enable approle`
  * https://www.vaultproject.io/docs/auth/approle
* `vault write auth/approle/role/jenkins-role token_num_uses=0 secret_id_num_uses=0 policies="jenkins"`
* `vault read auth/approle/role/jenkins-role/role-id`
	* copy the role_id and store somewhere
* `vault write -f auth/approle/role/jenkins-role/secret-id`

##### 2. Now go to jenkins > Manage  Jenkins >Manage Credentials > system > Add credentials > Vault App Role Credentials > paste roleid and secret id token we create in Vault and save and apply.
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/approleVault.png) 


 ### Stage-02: SonarQube integration with Jenkins
1. Open SonarQube and login using admin username and admin password
1. Create a Project >Enter Project name, Project key > click on setup
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/sonarqubedb.png)
1. Create sonarqube token > and save it soemwhere
1. click on continue > Run analysis on your project > maven > copy following commands and save it some where
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/soanr.png)
1. Now go to jenkins >Manage Credentials > system > Add credentials > secret text file > paste token we create in sonarqube and save and apply.

1. go to manage Jenkins > Configure System > Add SonarQube Server name,url and credentials
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/sonarqube.png)
1. go to manage Jenkins > Global tool configuration >  Add Maven and SonarQube Scanner

1. Now go to SonarQube > Quality gates > create your own quality gate
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/quality%20gate.png)
1. Add conditions with your own requirement
1. Select your project and Set this quality gate as defalut
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/qualiygate.png)
1. Now go to your Project > project setting > webhook
1. create webhook with your Jenkins url
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/webhook.png)

### Stage-03 : Add jenkins user to docker group
 ```sh 
sudo gpasswd -a jenkins docker
 ``` 
### Stage-04: Install and Configure AWS CLI
 1.Installation Guide is Available here https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  or you can use brew install awscli in MAC
1. go to AWS > create access key and secret key
1. configure aws cli using
```sh 
aws configure
 ``` 
paste your  access key and secret key 
#### Method 1
configure aws cli for jenkins user also 

##### Note – in this project i used  method 1 but you can also use method 2

#### Method 2 
1. go to jenkins > Manage Credentials > system > Add credentials > AWS credentials > give your access key and secret key > save


### Stage-05: DockerHub Integeration with jenkins for docker login
1. go to DockerHub > login into DockerHub
1. go to Account setting > security > generate a token 
1. copy this token and save it some where

##### in this project i used Hashicorp Vault to store my credentials for security purpose  but you can directly store in jenkins also . 
To store secrets into Vault-
#### Commands to store `docker` secret into Vault

* `vault secrets enable -path=secrets kv`
  * https://www.vaultproject.io/docs/secrets/kv
* `vault write secrets/creds/docker username=your-dockerhub-username password=token-generated-in-dockerhub`
* Create jenkins-policy.hcl
```
path "secrets/creds/*" {
 capabilities = ["read"]
}
```
* `vault policy write jenkins jenkins-policy.hcl`

1. Now go to jenkins > Manage credentials > global > create credentials with ‘vault username-password credentials ’
1. give path of your credentials ‘secrets/creds/docker’ 
1. give username key as username and password key as password
1. give id name as you wish and description and save it 

### Stage-06 : kubernetes Integeration  with jenkins
1. go to jenkins > Manage credentials > System ( global) > Add credentials > tkind - Kubernetes configuration ( Kuberconfig)
1. give id and description
1. go to kubeconfig > Enter directly

 Now you have to copy the content of your kubeconfig file of your cluster.
for that -
1. go to your home directory , you will find  ` .kube` 
1. change your directory to .kube and cat your config file

You will find your kubeconfig like this 
```sh 
apiVersion: v1
clusters:
- cluster:
    certificate-authority:  /home/michael-admin/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Fri, 24 Feb 2023 19:17:00 IST
        provider: minikube.sigs.k8s.io
        version: v1.28.0
      name: cluster_info
    server: https://x.x.x.x:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Fri, 24 Feb 2023 19:17:00 IST
        provider: minikube.sigs.k8s.io
        version: v1.28.0
      name: context_info
    namespace: default
    user: minikube
  name: minikube
- context:
    cluster: ""
    namespace: dev
    user: ""
  name: my-context
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/michael-admin/.minikube/profiles/minikube/client.crt
    client-key: home/michael-admin/.minikube/profiles/minikube/client.key
```


Now copy the config file data and paste into jenkins > save

### Stage-07 : Slack Integeration with Jenkins
1. Open Slack > create workspace > create channel
1. Now go to this site https://slack-t8s2905.slack.com/apps/new/A0F7VRFKN-jenkins-ci
1. Now choose your channel name

![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/slack.png)
1. Click on Add Jenkins CI inetegration
1. Copy the workspace name and token
1. store your secret token into Hashicorp Vault

* `vault write secrets/creds/slack secret=your-slack-token `
1. Now go to jenkins > Manage credentials > system (global ) > Vault sceret text credentials 
1. give your vault sercrets path, Vault key and save
1. Now go to configure system > slack > give your slack name and select credentials , give your Default channel name like ‘#devops’
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/slcakws.png)


#  Make sure you have all your installations as below either in ~/.bash_profile or in ~/.zshrc

```sh
export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME="/usr/local/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"
export M2_HOME=/usr/local/Cellar/maven/3.9.6
export PATH=$M2_HOME/bin:$PATH
export PATH="/usr/local/bin/trivy:$PATH"
export PATH="/usr/local/bin:$PATH"
export VAULT_ADDR='http://127.0.0.1:8200'

```
# We integrated all the tools with Jenkins, Now Create a declarative jenkins  pipeline for each stage.

## Step: 3 Pipeline creation

### General Jenkins  declarative Pipeline Syntax
I used Tools, Declarative Pipeline beccause we required build tool called maven

```sh 
pipeline {
    agent any
    tools {
        maven 'apache-maven-3.0.1' 
    }
    stages {
        stage('Example') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
```

### Stage-01 : Git Checkout 
1. Defiine a stage as git checkout
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for checkout: check out version control
1. give your github url, branch and generate the pipeline synatx
1. paste it into stage steps git check

```sh 
    stages {
        stage('Checkout git') {
            steps {
               git branch: 'master', url: 'https://github.com/oshaye3/devsecops-project-first'
            }
        }
```

### Stage-01.1 : Pre-build, Checkov, TF infra deploy and OWASP

```  sh 
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
```
### Stage-02 : Build and Junit test
1. Defiine a stage as Build and Junit test 
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for sh:shell script 
1. give your shell comman and generate the pipeline synatx
1. paste it into stage >  steps > sh ‘ shell command’
1. after build success , we want to test the code using junit
1. go to https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for Junit:Archived Junit-formatted test result
1. give your xml test cases file > generate pipeline syntax
1. paste it into post success

```sh
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
```
### Stage-03 : SonarQube Analysis
In this stage i used withSonarQubeEnv to  Prepare SonarQube Scanner environment
and shell command sh
1. Define  a stage SonarQube Analysis
1. paste the command that we created at the time of sonarqube project creation
```sh
stage('SonarQube Analysis'){
	steps{
	    withSonarQubeEnv('SonarQube-server') {
		sh 'mvn clean verify sonar:sonar \
		-Dsonar.projectKey=devsecops-project-key \
		-Dsonar.host.url=$sonarurl \
		-Dsonar.login=$sonarlogin'
		}
	}
}

```
### Stage-04 : Quality gate
This step pauses Pipeline execution and wait for previously submitted SonarQube analysis to be completed and returns quality gate status. Setting the parameter abortPipeline to true will abort the pipeline if quality gate status is not green.
1. Defiine a stage as Quality gate
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for  waitForQualityGate: Wait for SonarQube analysis to be completed and return quality gate status
1. generate pipeline syntax and paste it into steps
1. timeout is optional 
```sh
stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
```
### Stage-05 : Docker Build
First write your dockerfile to build docker images.I have posted my  dockerfile here https://github.com/oshaye3/devsecops-project-first/blob/main/Dockerfile .

In this stage i  shell command sh to build docker image
1. Define  a stage Docker Build
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for sh:shell script 
1. give your shell command to build image > generate pipeline syntax
1. I used build id of jenkins to make versions of docker images

```sh
        stage('Docker  Build') {
            steps {
                    sh '${DOCKER_PATH} build -t moshaye/sprint-boot-app:v1.$BUILD_ID .'
                    sh '${DOCKER_PATH} image tag moshaye/sprint-boot-app:v1.$BUILD_ID moshaye/sprint-boot-app:latest'
            }
        }
```
### Stage-06: Trivy Image scan
In this stage i  trivy shell command sh to scan docker image
1. Define  a stage Trivy Image scan
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for sh:shell script 
1.  give your Trivy shell command to scan build image
#### Note – There are 3 types of report output  format of trivy ( Table , JSON, Template). I used  html template for output report of trivy scan
```sh
        stage('Image Scan') {
            steps {
                // Disables secret scanning and sets the timeout to 30 minutes
                sh '/usr/local/bin/trivy image  --debug  --timeout 30m0s --scanners vuln --format template --template "@/usr/local/bin/html.tpl" -o report.html moshaye/sprint-boot-app:latest'
            }
        }
```
### Stage-07: Upload report generated by trivy to AWS S3
In this stage i  shell command sh to scan docker image
1. Define  a stage Upload report to AWS S3
1. first create a AWS s3 bucket 
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for sh:shell script
1. give your shell command to upload object to aws s3

```sh
        stage('Upload Scan report to AWS S3') {
              steps {
                  sh 'aws s3 cp report.html s3://michael-devsecops'
              }
         }
```
#### Note – in this Porject i configure aws cli for jenkins user also and execute just shell command . But you can use another method , save your credentials into jenkins and generate a pipeline to upload object to s3.
For that - S3 plugins should be installed
Pipeline Syntax 
```sh 
stage("Upload"){
	steps{
	      withAWS(region:"${region}", credentials:"${aws_credential}){
		s3Upload(file:"${TAG_NAME}", bucket:"${bucket}", path:"${TAG_NAME}/")
		  } 
	      }	  
}
 ``` 
### Stage-08: Push Docker images to DockerHub
In this stage i  shell command sh to push docker image to docker hub. I stored Credentials into Vault and access into jenkins using  vault key. You can store DockerHub credentials into jenkins and use as environment variables
1. Define  a stage Docker images push
1. go to this site https://opensource.triology.de/jenkins/pipeline-syntax/
1. search for sh:shell script
1. give your shell command to push docker images to docker hub

 ``` sh

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
 ``` 
### Stage-08: Deploy to kubernetes
write your kubernetes  deployment and service manifest.Find my kubernetes manifest here https://github.com/oshaye3/devsecops-project-first/blob/main/spring-boot-deployment.yaml .

Now generate pipeline syntax:- 
For this Kubernetes continuous Deploy plugins should be installed
1. go to jenkins > your project > pipeline syntax > search for kubernetesDeploy: Deploy to kubernetes
1. choose your kubeconfig , we created kubeconfig credentials into stage 6 kubernetes Integeration with jenkins
1. generate pipeline syntax
1. write your kubernetes manifest name  into configs: 'your-k8s-manifest-name'
 ```sh
        stage('Deploy to k8s') {
            steps {
                script{
                    kubernetesDeploy configs: 'spring-boot-deployment.yaml', kubeconfigId: 'kube-jenkins'
                }
            }
        }
```
## Stage: Post build action 
In post build action i used slack notification . After  build jenkins will send notification massage to slack whether your build success or failed.
1. go to jenkins > your project > pipeline syntax > search for slacksend: send slack message 
1. write your channel name and message > generate pipeline synatx .
#### Note – i used custom messages for my project . I Created a function for slack notification and called the function into post build .
 ```sh
post{
	always{
		sendSlackNotifcation()
	}
}
```
sendSlackNotification function 
 ```sh
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
 ```
#### Find whole pipeline here https://github.com/oshaye3/devsecops-project-first/blob/main/Jenkinsfile 

## Step: 4 Projecct Output

# Final outputs of this Project
### Jenkins Output : 
After 86th  Build my  jenkins pipeline became successful. 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/pipelineop.png) 

### Sonarqube Output: 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/sonarqubeop.png) 

### Quality Gate Status in Jenkins
This Output is the build number 106th. SonarQube Quality gate status is green and passed .   
You applied your custom quality gate like : there should be zero ( bug, Vulnerability , code smell ) and your code have greater then 0 (bugs, vulnerability , code smells) . Then your quality gate status will become failure or red. If your quality gate status beome failure , stages after quality gate will be failure.
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/qualitygateop.png) 

### Trivy report in AWS S3 push by jenkins ( You can also do presigned URL to view the trivy report)
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/trivy-report-s3.png) 


### Trivy report stored in the s3 bucket ( You can also do presigned URL to view the trivy report)
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/TrivyReprt.png) 


### Images in DockerHub pushed by jenkins 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/dockerhubop.png) 

### kubernetes output ( deployment and service created by jenkins) 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/kubernetesop.png) 

### Application output deployed in k8s 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/spring-boot-app-op.png) 

### Slack output 
![](https://github.com/oshaye3/devsecops-project-first/blob/master/Images/slackop.png) 


### You can check other screen-shot-devsecops.docx from this project:
https://github.com/oshaye3/devsecops-project-first/blob/master/screen-shot-devsecops.docx

