#!/bin/sh
set -euo pipefail
echo $$ > /var/run/github-runners.${RUNNER_NAME}
while [ -f /var/run/github-runners ] ; do
	# Should be a no-op, but check it isn't running before we do a rollback
	pot stop -p ${RUNNER_NAME}
	pot rollback -p ${RUNNER_NAME}
	pot start -p ${RUNNER_NAME}
	pot stop -p ${RUNNER_NAME}
done
