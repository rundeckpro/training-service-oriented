#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo >&2 "usage: add-project project"
    exit 1
fi
PROJECT=$1

echo "Create project $PROJECT..."
# Create the project as the rundeck user to ensure proper permissions.
su - rundeck -c "rd-project -a create -p $PROJECT"

# Run simple commands to sanity check the project.
su - rundeck -c "dispatch -p $PROJECT" > /dev/null
# Fire off a command.
su - rundeck -c "dispatch -p $PROJECT -f -- whoami"


echo "Project $PROJECT created."
