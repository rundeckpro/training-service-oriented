#!/usr/bin/env bash

# Exit immediately on error or undefined variable.
set -e 
set -u

# Process command line arguments.

if [ $# -lt 3 ]
then
    echo >&2 "usage: $0 name IP rundeck_yum_repo"
    exit 1
fi
NAME=$1
IP=$2
RUNDECK_REPO_URL=$3

# Software install
# ----------------

#
# JRE
#
yum -y install java7

# Rundeck 
#
if [ -n "$RUNDECK_REPO_URL" ]
then
    curl -# --fail -L -o /etc/yum.repos.d/rundeck.repo "$RUNDECK_REPO_URL" || {
        echo "failed downloading rundeck.repo config"
        exit 2
    }
else
    if ! rpm -q rundeck-repo
    then
        rpm -Uvh http://repo.rundeck.org/latest.rpm 
    fi
fi
yum -y install rundeck

# 2.0 uses newer jetty. This should eventually be fixed in the rpm.
sed -i "s/org.mortbay/org.eclipse/g" /etc/rundeck/jaas-loginmodule.conf

# Add the HipChat plugin
if [[ ! -f  /var/lib/rundeck/libext/rundeck-hipchat-plugin-1.0.0.jar ]]
then
cp /vagrant/rundeck-hipchat-plugin-1.0.0.jar /var/lib/rundeck/libext/
chown rundeck:rundeck /var/lib/rundeck/libext/rundeck-hipchat-plugin-1.0.0.jar
echo "HipChat plugin installed."
fi

if [[ ! -f  /var/lib/rundeck/libext/PagerDutyNotification.groovy ]]
then
curl -s --fail -L https://raw.github.com/rundeck-plugins/pagerduty-notification/master/src/PagerDutyNotification.groovy -o /var/lib/rundeck/libext/PagerDutyNotification.groovy
cat >>/etc/rundeck/framework.properties <<EOF
framework.plugin.Notification.PagerDutyNotification.service_key=value
EOF
echo "PagerDuty plugin installed."
fi
chown -R rundeck:rundeck /var/lib/rundeck/libext

#
# Disable the firewall so we can easily access it from any host.
service iptables stop
#

# Configure rundeck.
# -----------------


#
# Configure the mysql connection and log file storage plugin.
cd /etc/rundeck

cp /vagrant/provisioning/id_rsa* /var/lib/rundeck/.ssh/
chown rundeck:rundeck /var/lib/rundeck/.ssh/

# Update the framework.properties with name
sed -i \
    -e "s/localhost/$NAME/g" \
    -e "s,framework.server.url = .*,framework.server.url = http://$IP:4440,g" \
    -e "s,framework.rundeck.url = .*,framework.rundeck.url = http://$IP:4440,g" \
    framework.properties

sed -i \
    -e "s,grails.serverURL=.*,grails.serverURL=http://$IP:4440,g" \
    rundeck-config.properties

chown rundeck:rundeck framework.properties


# Start up rundeck
# ----------------

# Check if rundeck is running and start it if necessary.
# Checks if startup message is contained by log file.
# Fails and exits non-zero if reaches max tries.

set +e; # shouldn't have to turn off errexit.

source /vagrant/provisioning/functions.sh
success_msg="Connector@"
if ! service rundeckd status
then
    echo "Starting rundeck..."
    (
        exec 0>&- # close stdin
        service rundeckd start 
    ) &> /var/log/rundeck/service.log # redirect stdout/err to a log.

    wait_for_success_msg "$success_msg" /var/log/rundeck/service.log 

fi

echo "Rundeck started."


# Done.
exit $?
