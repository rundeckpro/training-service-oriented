#!/bin/bash

[[ $# -eq 2 ]] || {
	printf >&2 "Usage: $0 node script\n"
	exit 2
}
set -o nounset -o pipefail

##
# This script will be executed on each matched node for the workflow.
##
NODE=$1
PYTHON_SCRIPT=$2
##
# Arguments defined in the plugin.yaml will be passed to the script
##

# RD_CONFIG_SCRIPT: the python statements to execute

printf -- "---\n"
printf "Begin ...\n"

printf "%s [%s]: " "${RD_JOB_LOGLEVEL:-}" "${NODE:-}"
#python -c "$PYTHON_SCRIPT"
cat <<EOF | python -
$PYTHON_SCRIPT
EOF
rc=${PIPESTATUS[1]}
printf "End.\n"
printf -- "---\n"
exit $?