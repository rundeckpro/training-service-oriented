#!/usr/bin/env bash

# Exit immediately on error or undefined variable.
set -e 
set -u

# Process command line arguments.
# ----------------

# Software install
# ----------------

#
# JRE
#
yum -y install java-1.6.0
#
# Jenkins
#

curl -# --fail -L -o /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo || {
    echo "failed downloading jenkins.repo config"
    exit 3
}
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

#yum -y install jenkins

rpm -i http://pkg.jenkins-ci.org/redhat/jenkins-1.529-1.1.noarch.rpm

mkdir -p /var/lib/jenkins/examples
cp /vagrant/provisioning/simple-1.0.0.war /var/lib/jenkins/examples
chown -R jenkins:jenkins /var/lib/jenkins/examples
echo "Sample war file: $(ls /var/lib/jenkins/examples)"

# Configure jenkins.
# -----------------


# Start up jenkins
# ----------------

source /vagrant/provisioning/functions.sh
success_msg="Jenkins is fully up and running"
if ! service jenkins status
then
    service jenkins start 
    wait_for_success_msg "$success_msg" /var/log/jenkins/jenkins.log
fi

echo "Jenkins started."
service iptables stop


# Install the rundeck plugin using the jenkins CLI.
curl -s --fail -o jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin \
	http://updates.jenkins-ci.org/download/plugins/rundeck/2.11/rundeck.hpi

# Configure the plugin.
cp /vagrant/provisioning/jenkins/org.jenkinsci.plugins.rundeck.RundeckNotifier.xml /var/lib/jenkins/
chown jenkins:jenkins /var/lib/jenkins/org.jenkinsci.plugins.rundeck.RundeckNotifier.xml

# Load job definiton.
java -jar jenkins-cli.jar -s http://localhost:8080 create-job simpleapp \
	< /vagrant/provisioning/jenkins/simpleapp.xml

# Restart it to finilize the install.
java -jar jenkins-cli.jar -s http://localhost:8080 safe-restart



# Done.
exit $?
