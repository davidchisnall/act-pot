#!/bin/sh
set -eo pipefail
SCRIPTDIR=$(realpath $(dirname $0))
. ${SCRIPTDIR}/check-envs.sh

# We are going to reinject the configuration from a prior config directory,
# error out if it doesn't exist.
if [ ! -d "${RUNNER_CONFIG_DIRECTORY}" ] ; then
	echo Runner config directory ${RUNNER_CONFIG_DIRECTORY} not found.
	exit 1
fi

# Add the flavour that imports the config from the current directory and make
# sure that we're in the directory with the files that it expects.
RUNNER_FLAVOURS="github-act-import-config ${RUNNER_FLAVOURS}"
cd ${RUNNER_CONFIG_DIRECTORY}

. ${SCRIPTDIR}/create-runner.sh
