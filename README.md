# EtcKeeper Module

## Overview

The **EtcKeeper** module configures and installs etckeeper on client puppet machines.

Etckeeper records all changes to a machines configuration in `/etc` in the Git version control system. This allows changes to a machine's configuration to be audited and for bad changes to be reverted.

## Configuration

There is a template configuration file in `etckeeper.conf.erb` in the puppet master directory. This is the etckeeper configuration file that gets distributed to all clients.

It is best to leave `VCS="git"` because this module does not handle package dependencies for other version control systems.

## Dependencies

The module depends on the following puppet modules:

* NoConfigPkgs

This module collaborates with the PuppetClient module which installs pre- and post- puppet run scripts that record the machine configuration before and after each puppet run. Using these scripts is optional. To get the PuppetClient to enable these scripts the prerun_command and post_runcommand properties must be set under the `Client` key in Hiera like in this example:

	Clients :
	    server : 'puppet'
	    runinterval : '20m'
	    prerun_command : /etc/puppet/etckeeper-commit-pre
	    postrun_command : /etc/puppet/etckeeper-commit-post

The scripts are actually enabled by default in the global.yaml datasource in Hiera so as long as the `Clients` key is not overriden by the current environment these scripts should be enabled automatically.
