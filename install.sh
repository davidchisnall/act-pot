#!/bin/sh
set -euo pipefail
POT=$(which pot)
FLAVOURS=$(dirname ${POT})/../etc/pot/flavours
if [ ! -d ${FLAVOURS} ]; then
	echo "Can't locate pot install"
	exit 1
fi
echo Installing flavours to $(realpath ${FLAVOURS})
install -m 644 flavours/github-act flavours/github-act-configured ${FLAVOURS}
install flavours/github-act.sh ${FLAVOURS}
install run-actions-runner.sh /usr/local/bin/
install gh_actions /usr/local/etc/rc.d/

