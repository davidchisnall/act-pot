#!/bin/sh
set -euo pipefail
if [ -f /var/run/github-runners.${RUNNER_NAME} ]; then
	echo ${RUNNER_NAME} already running.
	echo Please delete /var/run/github-runners.${RUNNER_NAME} if the system did not gracefully shut down.
	exit 1
fi
RUNNER_CLONE_NAME=${RUNNER_NAME}-ephemeral
cleanup() {
	echo Signal received, exiting...
	pot stop -p ${RUNNER_CLONE_NAME}
	pot destroy -p ${RUNNER_CLONE_NAME}
	rm /var/run/github-runners.${RUNNER_NAME}
}
trap cleanup INT
echo $$ > /var/run/github-runners.${RUNNER_NAME}
while [ -f /var/run/github-runners ] ; do
	if [ "$(cat /var/run/github-runners.${RUNNER_NAME})" != $$ ] ; then
		exit 0
	fi
	# Acquire a lock while cloning to prevent races against an update of the base image.
	lockf -k /var/run/github-runners.${RUNNER_NAME}.lock pot clone -F -P ${RUNNER_NAME} -p ${RUNNER_CLONE_NAME}
	pot start -p ${RUNNER_CLONE_NAME}
	pot destroy -p ${RUNNER_CLONE_NAME}
done
rm /var/run/github-runners.${RUNNER_NAME}
