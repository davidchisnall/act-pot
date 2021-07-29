Wrapper scripts to run GitHub actions in a jail on FreeBSD
==========================================================

*DISCLAIMER*: This uses [a third-party implementation of the GitHub Actions protocol](https://github.com/ChristopherHX/github-act-runner) and is not officially supported by GitHub.

This repository provides some scripts to run CI driven from GitHub in a FreeBSD jail.
It uses `pot` to manage the jails.
The pot runs one action and then stops, the underlying ZFS filesystem is restored to a snapshot, and the pot restarts.
This allows the actions to do whatever they need to as root in the jail (install software, whatever).
*This is a work in progress, please file issues as you find them.*

Installing and configuring a runner
-----------------------------------

Install with `./install.sh`.
This will install a `pot` flavour and the RC scripts required to run the jails.
Register a GitHub action by [following the directions from GitHub](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners).
When you are asked to select an operating system, select Linux.
Ignore all of the commands that you are instructed to run except for the one that starts `./config`.
Paste that command into a root terminal in the directory where you have cloned this repository.

Two environment variables affect this command:

 - `FREEBSD_VERSION` specifies the version of FreeBSD to use (e.g. 13.1).
   If not specified this is the version of your host system.
 - `RUNNER_NAME` specifies the name to give to this runner.
   If not specified then this is the {your hostname}-freebsd-{version number}.

This script will create a pot (container) that has a configured GitHub Actions runner inside.
It will also create a snapshot of the pot.
The name of the pot is the runner name with any dots replaced with underscores (pot names are not allowed to contain dots).
The runner will have `freebsd` and `freebsd-{version}` labels, these can be used to select runners with the `runs-on` property in the YAML.

This pot can be exported and imported on another system using the [existing pot commands](https://pot.pizzamig.dev/Container/).

Installing dependencies
-----------------------

You can modify the pot to install dependencies such as compilers or other tools.
If you do then you must snapshot the pot *after* installing dependencies.
You can update the base-system image in the same way.

*IMPORTANT:* The script that runs the action runner reverts to the last snapshot after each action run.
If you do not create a new snapshot then all of your changes will be discarded.

Running the runners
-------------------

The install script will install a `gh_actions` RC script.
This is controlled by two variables in `/etc/rc.conf` (or any of the equivalent places):

 - `gh_actions_enable`, set this to `"YES"` to enable starting runners automatically.
 - `gh_actions_pots` is a space-separated list of pot names for the action runners.

Once these are set, `service gh_actions start` will start all configured runners.
`service gh_actions stop` will stop all runners.
*Note*: There is a bug in the current version of `pot` that prevents starting a pot immediately after it was forcibly stopped.

Using the runners
-----------------

The runners appear like any other GitHub Actions runners.

```yaml
name: Example

# Controls when the workflow will run
on:
  # Triggers the workflow on push
  push:
  
  # Triggers the workflow on pull-request
  pull_request:

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  # This is just a name
  freebsd:
    # Select any runner with the freebsd-12.2 tag.  This is added automatically
    # to runners that these scripts create from a 12.2 base.
    runs-on: freebsd-12.2
    name: Test in FreeBSD
    steps:
    # Use the existing (NodeJS) checkout action to clone the repo:
    - uses: actions/checkout@v2
    # Add any other GitHub actions here
    - name: Build
      run: {your build commands here}
```