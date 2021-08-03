#!/bin/sh
set -euo pipefail
RUNNER_CLONE_NAME=${RUNNER_NAME}-$(uuidgen)
echo $$ > /var/run/github-runners.${RUNNER_NAME}
while [ -f /var/run/github-runners ] ; do
	# Acquire a lock while cloning to prevent races against an update of the base image. 
	lockf -k /var/run/github-runners.${RUNNER_NAME}.lock pot clone -P ${RUNNER_NAME} -p ${RUNNER_CLONE_NAME}
	pot start -p ${RUNNER_CLONE_NAME}
	pot stop -p ${RUNNER_CLONE_NAME}
	pot destroy -p ${RUNNER_CLONE_NAME}
done
