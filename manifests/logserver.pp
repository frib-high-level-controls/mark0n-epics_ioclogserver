# This type manages an instance of the IOC log server.
#
define epics_ioclogserver::logserver(
  Optional[Enum['running', 'stopped']] $ensure           = undef,
  Optional[Boolean]                    $enable           = undef,
  String                               $logfile,
  Integer[1, 65535]                    $port             = 7004,
  Array[String]                        $systemd_after    = [ 'network.target' ],
  Array[String]                        $systemd_requires = [ 'network.target' ],
  String                               $username         = "ioclog-${name}",
)
{
  include 'epics_ioclogserver'

  systemd::unit_file { "iocLogServer-${name}.service":
    content => template("${module_name}/etc/systemd/system/iocLogServer.service"),
    notify  => Service["iocLogServer-${name}"],
  }

  logrotate::rule { "iocLogServer-${name}":
    path         => "/var/log/iocLogServer-${name}.log",
    rotate_every => 'day',
    rotate       => 30,
    size         => '100M',
    missingok    => true,
    ifempty      => false,
    postrotate   => "/bin/systemctl kill --signal=HUP --kill-who=main iocLogServer-${name}.service",
  }

  service { "iocLogServer-${name}":
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'systemd',
    require    => [
      Class['epics_ioclogserver'],
      Class['systemd::systemctl::daemon_reload'],
    ],
  }
}