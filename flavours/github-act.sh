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
cp github-act-runner /usr/local/bin/github-act-runner

# Create the config directory
mkdir /root/runner

# Provide a wrapper script to run the action runner once.
cat <<EOF > /root/ci.sh
#!/bin/sh
cd /root/runner
github-act-runner run --once
EOF
chmod +x /root/ci.sh
