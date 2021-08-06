Wrapper scripts to run GitHub actions in a jail on FreeBSD
==========================================================

*DISCLAIMER*: This uses [a third-party implementation of the GitHub Actions protocol](https://github.com/ChristopherHX/github-act-runner) and is not officially supported by GitHub.

This repository provides some scripts to run CI driven from GitHub in a FreeBSD jail.
It uses `pot` to manage the jails.
The pot is cloned from an immutable ZFS filesystem, runs one action,  stops, the underlying ZFS filesystem is destroyed, and then the process repeats.
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

Three environment variables affect this command:

 - `FREEBSD_VERSION` specifies the version of FreeBSD to use (e.g. 13.1).
   If not specified this is the version of your host system.
 - `RUNNER_NAME` specifies the name to give to this runner.
   If not specified then this is the {your hostname}-freebsd-{version number}.
 - `RUNNER_FLAVOURS` specifies a space-separated list of flavours that will be applied to the pot.
   This allows you to provide a set of additional tools that will be made available to runner actions.

This script will create a pot (container) that has a configured GitHub Actions runner inside.
The name of the pot is the runner name with any dots replaced with underscores (pot names are not allowed to contain dots), the script will output this on the last line of the output.
The runner will have `freebsd` and `freebsd-{version}` labels, these can be used to select runners with the `runs-on` property in the YAML.

The runner's configuration is exported from into `runners/{pot name}`, allowing the runner to be re-created without having to re-register it with GitHub.
This exported configuration includes all of the environment variables that the script used when setting them up.

This pot can be exported and imported on another system using the [existing pot commands](https://pot.pizzamig.dev/Container/).
This pot will not be run directly by the scripts, it is treated as an immutable prototype and cloned for each invocation.

Installing dependencies
-----------------------

You can modify the pot to install dependencies such as compilers or other tools.
You can update the base-system image in the same way.

To make orchestration easier, you should provide your dependencies as one or more [`pot` flavours](https://pot.pizzamig.dev/Images/#images-creation-automated-with-flavours).
These can be injected into the pot by setting the `RUNNER_FLAVOURS` environment variable as outlined above.

Re-creating a runner
-------------------

The `recreate-runner.sh` script re-creates a runner.
This expects to find the `runners/{pot name}` directory containing the configuration.
This will read the environment variables that were provided to `config.sh` from `runners/{pot name}/act-config.sh`.
You can modify this to specify a newer FreeBSD base version (for example, moving from FreeBSD 12.2 to 12.3) or to change the set of flavours that are installed.
Note that recreating the runner will *not* change the labels and so you may need to manually modify labels that refer to the version if you replace a runner with a newer version.
If you wish to change the name of the pot when re-creating the runner (for example, to include a version or date) then you must copy or rename this directory.

Note that only one pot with any given name can exist on the system at a time and so you must either rename the pot or destroy the pot before recreating it.
Note that you can create the pot on one system, export it, and then import it on your deployment system.

If you have created your runners by providing flavours with all of the dependencies then this script allows you to generate a new version with all dependencies.

### Recreating all runners

The `recreate-all-runners.sh` script will recreate all runners that you have created.
This iterates over all of the configs in the `runners/` directory and so must be run from the same location as `config.sh`.
This can be run from a cron job to make sure that all runners have picked up the security updates.

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
