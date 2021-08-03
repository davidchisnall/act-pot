#!/bin/sh
set -eo pipefail
SCRIPTDIR=$(realpath $(dirname $0))

if [ "$1" != '--url' -o "$3" != '--token' ] ; then
	echo usage ./config.sh --url https://github.com/{account}/{repo} --token {token}
	echo Copy this command from the GitHub actions runner setup page
	exit 1
fi

. ${SCRIPTDIR}/check-envs.sh

mkdir -p ${RUNNER_CONFIG_DIRECTORY}
cd ${RUNNER_CONFIG_DIRECTORY}

if [ -f github.conf ]; then
	echo github.conf exists, aborting.
	echo Please delete github.conf and retry
	exit 1
fi

# Provide the configuration that the configure flavour script needs
echo "GITHUB_URL=$2" > github.conf
echo "GITHUB_TOKEN=$4" >> github.conf
echo "RUNNER_NAME=${RUNNER_NAME}" >> github.conf

echo "RUNNER_FLAVOURS=${RUNNER_FLAVOURS}" > act-config.sh
echo "FREEBSD_VERSION=${FREEBSD_VERSION}" >> act-config.sh
echo "RUNNER_NAME=${RUNNER_NAME}" >> act-config.sh
echo "POTNAME=${POTNAME}" >> act-config.sh

# Add the flavour that will configure the runner before any user-provided ones.
RUNNER_FLAVOURS="github-act-configure ${RUNNER_FLAVOURS}"

. ${SCRIPTDIR}/create-runner.sh

# Copy the configuration out of the jail.
# FIXME: pot does not provide any mechanism for doing this that doesn't involve
# poking at its internals.  If one is added then we should use it.
cp ${POT_MOUNT_BASE}/jails/${POTNAME}/m/root/runner/* ${RUNNER_CONFIG_DIRECTORY}
