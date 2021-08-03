#!/bin/sh

for I in `pwd`/runners/*/act-config.sh ; do
	if [ -f "$I" ] ; then
		RUNNER_FLAVOURS=
		FREEBSD_VERSION=
		RUNNER_NAME=
		POTNAME=
		. $I
		echo Recreating ${RUNNER_NAME}
		export RUNNER_FLAVOURS
		export FREEBSD_VERSION
		export RUNNER_NAME
		export POTNAME
		./recreate-runner.sh
	fi
done
