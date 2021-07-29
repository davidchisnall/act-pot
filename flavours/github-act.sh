#!/bin/sh
export PAGER=/bin/cat

# Update to the latest stable release
freebsd-update --not-running-from-cron fetch install
# Install dependencies
pkg ins -y git-lite node go bash

# Install the runner
git clone https://github.com/ChristopherHX/github-act-runner.git --recursive
cd github-act-runner/
go build
cp main /usr/local/bin/github-act-runner

# Source the configuration file.
. /root/github-config
cat /root/github-config

VERSION=$(freebsd-version -u | sed -r 's/-.*//')
# Configure the runner
mkdir /root/runner
cd /root/runner
/usr/local/bin/github-act-runner configure \
	--url ${GITHUB_URL} \
	--token ${GITHUB_TOKEN} \
	--name ${RUNNER_NAME} \
	--labels freebsd,"freebsd-${VERSION}"

# Provide a wrapper script to run the action runner once.
cat <<EOF > /root/ci.sh
#!/bin/sh
cd /root/runner
github-act-runner run --once
EOF
chmod +x /root/ci.sh
