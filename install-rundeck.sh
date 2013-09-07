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
yum -y install java-1.6.0
#
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



#
# Disable the firewall so we can easily access it from any host.
service iptables stop
#

# Configure rundeck.
# -----------------


#
# Configure the mysql connection and log file storage plugin.
cd /etc/rundeck

cp /vagrant/id_rsa* /var/lib/rundeck/.ssh/
chown rundeck:rundeck /var/lib/rundeck/.ssh/

# Update the framework.properties with name
sed -i \
    -e "s/localhost/$NAME/g" \
    -e "s,framework.server.url = .*,framework.server.url = http://$IP:4440,g" \
    -e "s,framework.rundeck.url = .*,framework.rundeck.url = http://$IP:4440,g" \
    framework.properties

chown rundeck:rundeck framework.properties


# Start up rundeck
# ----------------

# Check if rundeck is running and start it if necessary.
# Checks if startup message is contained by log file.
# Fails and exits non-zero if reaches max tries.

set +e; # shouldn't have to turn off errexit.

function wait_for_success_msg {
    success_msg=$1
    let count=0 max=18

    while [ $count -le $max ]
    do
        if ! grep "${success_msg}" /var/log/rundeck/service.log
        then  printf >&2 ".";#  output message.
        else  break; # successful message.
        fi
        let count=$count+1;# increment attempts count.
        [ $count -eq $max ] && {
            echo >&2 "FAIL: Execeeded max attemps "
            exit 1
        }
        sleep 10; # wait 10s before trying again.
    done
}

mkdir -p /var/log/vagrant
success_msg="Started SocketConnector@"

if ! service rundeckd status
then
    echo "Starting rundeck..."
    (
        exec 0>&- # close stdin
        service rundeckd start 
    ) &> /var/log/rundeck/service.log # redirect stdout/err to a log.

    wait_for_success_msg "$success_msg"

fi

echo "Rundeck started."


# Done.
exit $?
