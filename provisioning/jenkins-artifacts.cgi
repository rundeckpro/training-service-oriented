#!/usr/bin/env bash

set -eu

JENKINS_URL=http://192.168.50.4:8080

echo Content-type: application/json
echo ""

for VAR in `echo $QUERY_STRING | tr "&" "\t"`
do
	NAME=$(echo $VAR | tr = " " | awk '{print $1}';);
	VALUE=$(echo $VAR | tr = " " | awk '{ print $2}' | tr + " ");
	declare $NAME="$VALUE";
done

if [[ -z "$build" ]]
then
	echo >&2 'no build query param'
	exit 2
fi
[[ -z "$appname" ]] && {
	echo >&2 'appname query param not specified'
	exit 2
}


base_url="$JENKINS_URL/job/$appname/ws"
war_name=$appname-1.0.$build.war
artifact="$base_url/$war_name"

printf "["
printf "{\"name\": \"%s\",\"value\":\"%s\"},\n" "$war_name" "$artifact"
printf "]\n"


