#/bin/sh
# Source the configuration file.
. /root/github-config
cat /root/github-config

VERSION=$(freebsd-version -u | sed -r 's/-.*//')
# Configure the runner
cd /root/runner
/usr/local/bin/github-act-runner configure \
	--url ${GITHUB_URL} \
	--token ${GITHUB_TOKEN} \
	--name ${RUNNER_NAME} \
	--labels freebsd,"freebsd-${VERSION}"

