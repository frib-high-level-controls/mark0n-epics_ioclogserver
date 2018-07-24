This Puppet module installs and configures an EPICS IOC log server. The log
server is run as a system service. Currently only systemd is supported as init
system (e.g. Debian >=8).

# Environment Variables

Some attributes of the `Epics_ioclogserver::logserver` class cause environment
variables to be set. Please refer to the following table for a list:

| Attribute | Environment Variable      |
|-----------|---------------------------|
| `logfile` | `EPICS_IOC_LOG_FILE_NAME` |
| `port`    | `EPICS_IOC_LOG_PORT`      |

# Example

## Simple

```
epics_ioclogserver::logserver { 'vacuum':
  ensure  => running,
  enable  => true,
  logfile => '/var/log/iocLogServer-vacuum.log',
}
```

## User managed externally

```
user { 'cryologger':
  ensure => present,
}

epics_ioclogserver::logserver { 'cryo':
  ensure      => running,
  enable      => true,
  logfile     => '/var/log/iocLogServer-cryo.log',
  manage_user => false,
  username    => 'cryologger',
  require     => User['cryologger'],
}
```

# Reference

## Class `epics_ioclogserver`

This class takes care of all global task which are needed in order to run an IOC
log server. It installs the needed packages. You generally don't need to use the
main class directly.

## Defined Type `epics_ioclogserver::logserver`

This type manages an EPICS IOC log server instance. The instance gets configured
and registered as a system service. This type automatically includes
`epics_ioclogserver`.

### `ensure`

Ensures the IOC log server service is running/stopped. Valid values are
`running`, `stopped`, and <undefined>. If not specified Puppet will not
start/stop the IOC service.

### `enable`

Whether the IOC log server service should be enabled to start at boot. Valid
values are `true`, `false`, and <undefined>. If not specified (undefined) Puppet
will not start/stop the IOC service.

### `logfile`

Allows to configure the `EPICS_IOC_LOG_FILE_NAME` environment variable for the IOC
log server.

### `logrotate_compress`

Whether to compress the log file when rotating it. Defaults to `true`.

### `logrotate_rotate`

The time in days after which a the log file will be rotated. Default is `30`.

### `logrotate_size`

If the log file reaches this size the log will be rotated. Default is `'100M'`.

### `port`

Allows to configure the `EPICS_IOC_LOG_PORT` environment variable for the IOC
log server. The default is 7004 (the default port used by iocLogServer).

### `systemd_after`

Ensures the IOC log server service is started after the specified `systemd`
units have been activated. Please specify an array of strings. Default:
`network.target`.

Note: This enforces only the correct order. It does not cause the specified
targets to be activated. Also see `systemd_requires`.

### `systemd_requires`

Ensures the specified `systemd` units are activated when this IOC log server is
started. Default: `network.target`.

Note: This only ensures that the required services are started. That generally
means that `systemd` starts them in parallel to the IOC log server service.
Please use `systemd_after` to ensure they are started before the IOC is started.

# Contact

Author: Martin Konrad <konrad at frib.msu.edu>