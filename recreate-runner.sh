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

FINAL_POT_NAME=${POTNAME}
POTNAME=${POTNAME}-tmp

echo Creating temporary pot ${POTNAME}

. ${SCRIPTDIR}/create-runner.sh

echo Renaming to ${FINAL_POT_NAME}

lockf -k /var/run/github-runners.${FINAL_POT_NAME}.lock ${SCRIPTDIR}/rename-runner.sh ${POTNAME} ${FINAL_POT_NAME}

# Tell the pot to gracefully shut down if it is not running any jobs.
echo 'pkill -INT github-act-runner' | pot term ${FINAL_POT_NAME}-ephemeral
