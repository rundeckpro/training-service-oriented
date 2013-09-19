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

[[ -z "$appname" ]] && {
	echo >&2 'appname query param not specified'
	exit 2
}

printf "["
curl -s --fail $JENKINS_URL/job/$appname/api/xml |
xmlstarlet sel -t -m //build -v number -n | while read build
do
 [[ -z "$build" ]] && continue
 printf "{\"name\": \"build #%s\",\"value\":\"%s\"},\n" "$build" "$build"
done

printf "]\n"
