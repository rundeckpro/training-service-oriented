#!/usr/bin/env bash

if [ $# -ne 3 ]
then
    echo >&2 "usage: install-tomcats IP rundeck_url project"
    exit 1
fi
IP=$1
RUNDECK_URL=$2
PROJECT=$3

# Exit immediately on error or undefined variable.
#set -e 
set -u

# Process command line arguments.
# ----------------

# Software install
# ----------------
# Utilities

curl -s http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -o epel-release.rpm -z epel-release.rpm
if ! rpm -q epel-release
then
    rpm -Uvh epel-release.rpm
fi
yum -y install xmlstarlet coreutils unzip nc



#
# JRE
#
yum -y install java-1.6.0

#
# Rerun 
#
RERUN_REPO_URL="https://bintray.com/ahonor/rerun-rpm/rpm"

curl -# --fail -L -o /etc/yum.repos.d/rerun.repo "$RERUN_REPO_URL" || {
    echo "failed downloading rerun.repo config"
    exit 3
}
yum -y install rerun rerun-rundeck-admin

# 
# Tomcat
#

TOMCAT_BASENAME="apache-tomcat-7.0.42"
TOMCAT_ZIP_URL="http://jcenter.bintray.com/org/apache/tomcat/tomcat/7.0.42/tomcat-7.0.42.zip"
curl -s --fail -L -z $TOMCAT_BASENAME.zip -o $TOMCAT_BASENAME.zip "$TOMCAT_ZIP_URL" || {
    echo >&2 "failed downloading tomcat binary."
    exit 3
}


unzip -o $TOMCAT_BASENAME.zip

[[ -d $TOMCAT_BASENAME ]] || {
	echo >&2 "$TOMCAT_BASENAME directory not found."
	exit 3
}

mkdir -p /usr/local

if ! grep -q tomcat /etc/group
then	
	groupadd tomcat
fi

mv $TOMCAT_BASENAME /usr/local/$TOMCAT_BASENAME
chmod 755 /usr/local/$TOMCAT_BASENAME/bin/*.sh
chgrp -R tomcat /usr/local/$TOMCAT_BASENAME

export CATALINA_HOME=/usr/local/$TOMCAT_BASENAME

echo "CATALINA_HOME=$CATALINA_HOME"

# 
#
#

# Register this host
os_info=(-osName "$(uname -s)" -osFamily unix -osArch "$(uname -p)" -osVersion "$(uname -r)")

rerun rundeck-admin:resource-add --user admin --password admin --url $RUNDECK_URL \
	--project $PROJECT \
    --model "-name $(hostname) -description 'tomcat server' -hostname $IP  -username rundeck ${os_info[*]}"


# Create the tomcat instances
for instance in 1 2 
do
	CATALINA_BASE=/home/tomcat${instance}
	echo "CATALINA_BASE=$CATALINA_BASE"


	# Add the login account.
	if ! id tomcat${instance} >/dev/null 2>/dev/null
	then
		useradd -m tomcat${instance} -d /home/tomcat${instance} -g tomcat \
			-c "application login for tomcat instance $instance" 
	fi

	# Copy the rundeck server ssh key to this account.
	mkdir -p $CATALINA_BASE/.ssh
	cp /vagrant/provisioning/id_rsa.pub $CATALINA_BASE/.ssh/authorized_keys2
	chmod 600 $CATALINA_BASE/.ssh/authorized_keys2
	chown -R tomcat${instance} $CATALINA_BASE/.ssh

	# Start defining the model for this node.
	model=(${os_info[*]} -hostname $IP -username tomcat${instance} -tags tomcat,tomcat${instance},$(hostname))
	model=(${model[*]} -catalina_base $CATALINA_BASE -catalina_home $CATALINA_HOME)
	model=(${model[*]} -rank ${instance} -simple_url http://$IP:${instance}8080/simple)

	mkdir -p $CATALINA_BASE/{logs,temp,work,bin}

	if [[ ! -d $CATALINA_BASE/conf ]]
	then cp -r $CATALINA_HOME/conf $CATALINA_BASE/conf
	fi
	sed -i \
		-e "s/8080/${instance}8080/g" \
		-e "s/8005/${instance}8005/g" \
		-e "s/8009/${instance}8009/g" \
		-e "s/8443/${instance}8443/g" \
		$CATALINA_BASE/conf/server.xml

	cat > $CATALINA_BASE/bin/startup.sh <<-EOF
	#!/bin/bash
	export CATALINA_HOME=$CATALINA_HOME
	export CATALINA_BASE=$CATALINA_BASE
	$CATALINA_HOME/bin/startup.sh
	EOF

	cat > $CATALINA_BASE/bin/shutdown.sh <<-EOF
	#!/bin/bash
	export CATALINA_HOME=$CATALINA_HOME
	export CATALINA_BASE=$CATALINA_BASE
	$CATALINA_HOME/bin/shutdown.sh
	EOF

	cat > $CATALINA_BASE/bin/status.sh <<-EOF
	#!/bin/bash
	if ! nc -z localhost ${instance}8009 >/dev/null
	then
		echo DOWN && exit 1
	else
		echo UP 
	fi
	EOF

	chmod 755 $CATALINA_BASE/bin/*.sh

	# Deploy the simple war file to the webapps directory.
	[[ ! -d $CATALINA_BASE/webapps ]] || rm -r $CATALINA_BASE/webapps
	mkdir $CATALINA_BASE/webapps-1.0.0
	cp /vagrant/provisioning/simple-1.0.0.war $CATALINA_BASE/webapps-1.0.0/simple.war
	(cd $CATALINA_BASE; ln -s webapps-1.0.0 webapps)
	chown -R tomcat${instance}:tomcat $CATALINA_BASE


	# Register this tomcat instance as a node
	#echo "model: ${model[*]}"
	rerun rundeck-admin:resource-add --user admin --password admin --url $RUNDECK_URL \
		--project $PROJECT \
		--model "-name $(hostname)-tomcat${instance} -description 'tomcat app instance $instance on $(hostname)' ${model[*]}"

	# Startup the new instance.
	echo "Starting the instance..."
	su - tomcat${instance} -c "$CATALINA_BASE/bin/startup.sh"

	echo "Access the webapp via http://$IP:${instance}8080/simple/"
done

#
# Disable the firewall so we can easily access it from any host.
service iptables stop
#

if ! id rundeck >/dev/null 2>/dev/null
then
	useradd -m rundeck 	-c "application login for rundeck" -d /home/rundeck
fi

mkdir -p /home/rundeck/.ssh
cp /vagrant/provisioning/id_rsa.pub /home/rundeck/.ssh/authorized_keys2
chmod 600 /home/rundeck/.ssh/authorized_keys2
chown -R rundeck /home/rundeck/.ssh



