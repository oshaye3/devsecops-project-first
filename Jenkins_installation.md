# For macOS:
# Step 1: Install Homebrew (if not already installed)
Homebrew is a package manager for macOS that simplifies the installation of software. Install it by running the following command in the terminal:

``` sh /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ```


# Step 2: Install Java

``` sh brew install openjdk@21 ```

If this version is not directly available, you might need to use a version manager for Java like jenv, or manually install the JDK from the official Oracle JDK or OpenJDK sources.

# Step 3: Set Java 21 as the Default Version
After installation, set up JAVA_HOME for Java 21 by adding it to your ~/.zshrc file. You'll typically find the installation in /usr/local/opt/openjdk@21, but you should verify this path since it can vary.
``` sh
echo 'export JAVA_HOME="/usr/local/opt/openjdk@21"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
Reload your ~/.zshrc to apply the changes:

source ~/.zshrc
```
# Step 4: Verify the Installation
 Check that the correct version of Java is being used:

``` sh java -version ```
The output should indicate that Java 21 is the current version.

# For Ubuntu 22.04:
If you're also looking to install Java 21 on Ubuntu 22.04, you would follow a similar approach, but adjusted for the Linux environment:

# Step 1: Install Java
You would typically add a PPA (Personal Package Archive) that includes Java 21 or download the JDK directly from the provider and install it manually.

If a PPA is available:
``` sh
sudo add-apt-repository ppa:some-ppa-that-contains-java-21
sudo apt-get update
sudo apt-get install openjdk-21-jdk
```
If you need to download it manually:

Download the tar.gz file for Linux from the official Oracle JDK or OpenJDK site.
Extract it to a desired location, for example, /usr/lib/jvm/java-21-openjdk-amd64/.
# Step 2: Set Java 21 as the Default Version
You can use update-alternatives to update the default Java version:
``` sh
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk-amd64/bin/java 1
sudo update-alternatives --config java
```
Select the appropriate choice for Java 21 if necessary.

# Step 3: Configure JAVA_HOME
Set JAVA_HOME by adding it to your ~/.bashrc or ~/.zshrc file:
``` sh
echo 'export JAVA_HOME="/usr/lib/jvm/java-
```  
Copy the 32-character alphanumeric password from the terminal and paste it into the Administrator password field, then click Continue.

# Jenkins INSTALLATION

Step 2: Install Jenkins
Add the Jenkins repository key to your system:
``` sh curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null ```
Append the Debian package repository address to your system's software repository list:

``` sh  
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```
Update your local package index:
``` sh 
sudo apt-get update
Install Jenkins:
sudo apt-get install jenkins
```
Step 3: Start Jenkins
``` sh 
Enable and start the Jenkins service:

sudo systemctl enable jenkins
sudo systemctl start jenkins
```
Check the status of the Jenkins service:
```sh
sudo systemctl status jenkins
```
Step 4: Open the Firewall
Allow traffic on port 8080 and enable OpenSSH through the firewall:
``` sh 
sudo ufw allow 8080
sudo ufw allow OpenSSH
sudo ufw enable
```
Step 5
Set Up Jenkins

Open your web browser and navigate to http://your_server_ip_or_domain:8080 to access the Jenkins interface.
Retrieve the initial admin password:
``` sh  sudo cat /var/lib/jenkins/secrets/initialAdminPassword ```
Copy the 32-character alphanumeric password from the terminal.
Back in the web interface, paste this password into the "Administrator password" field and click "Continue".


# For macOS:


Step 1: Install Homebrew (if not already installed)
Homebrew is a package manager for macOS that simplifies the installation of software. Install it by running the following command in the terminal:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Step 3: Install Jenkins
Install Jenkins with Homebrew:
``` sh brew install jenkins-lts ```
To have launchd start jenkins-lts now and restart at login:
brew services start jenkins-lts
Or, if you don't want Jenkins to start at login:
``` sh 
sudo brew services start jenkins-lts
```
Step 4: Access Jenkins
Open your web browser and navigate to http://localhost:8080 to access the Jenkins interface.
Retrieve the initial admin password:
``` sh  
cat ~/.jenkins/secrets/initialAdminPassword
```
Copy the password displayed in your terminal.
In the web interface, paste this password into the "Administrator password" field and click "Continue".
Please note that firewall settings on macOS are managed through the System Preferences and are typically not required for local installations. If you are setting up Jenkins on a Mac that's accessible over a network and need to modify firewall settings, you can do so in "System Preferences" > "Security & Privacy" > "Firewall".

For both Ubuntu and macOS, after completing the initial setup, you will be prompted to install plugins and create a user account for Jenkins. Follow the on-screen instructions to complete the Jenkins installation.




