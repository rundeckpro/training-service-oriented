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
    echo "failed downloading rundeck.repo config"
    exit 3
}
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

yum -y install jenkins

mkdir -p /var/lib/jenkins/examples
cp /vagrant/simple-1.0.0.war /var/lib/jenkins/examples
chown -R jenkins /var/lib/jenkins/examples
echo "Sample war file: $(ls /var/lib/jenkins/examples)"

# Configure jenkins.
# -----------------


# Start up jenkins
# ----------------

if ! service jenkins status
then
    echo "Starting jenkins..."
    exec 0>&- # close stdin
    service jenkins start 
fi

echo "Jenkins started."

# Load job definiton.
# java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar \
#      -s http://localhost:8080 create-job < status.xml


# Done.
exit $?
