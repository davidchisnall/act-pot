if [ ! "${FREEBSD_VERSION}" ] ; then
	FREEBSD_VERSION=$(freebsd-version -u | sed -r 's/-.*//')
	echo FREEBSD_VERSION not set, using ${FREEBSD_VERSION}
fi
if [ ! "${RUNNER_NAME}" ] ; then
	RUNNER_NAME=$(hostname)-freebsd-${FREEBSD_VERSION}
	echo RUNNER_NAME not set, using ${RUNNER_NAME}
fi
if [ ! "${POT_MOUNT_BASE}" ] ; then
	POT_MOUNT_BASE=/opt/pot/
	echo POT_MOUNT_BASE not set, using ${POT_MOUNT_BASE}
fi
# Set the pot name to use underscores in place of dots (the one character pot
# names are apparently not allowed).
# FIXME: We shouldn't be allowing anything that isn't allowed in a path
# component here either.
POTNAME=$(echo ${RUNNER_NAME} | sed 's/\./_/g')
RUNNER_CONFIG_DIRECTORY=`pwd`/runners/${POTNAME}
