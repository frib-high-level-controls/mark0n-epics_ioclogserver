# This type manages an instance of the IOC log server.
#
define epics_ioclogserver::logserver(
  Optional[Enum['running', 'stopped']] $ensure             = undef,
  Optional[Boolean]                    $enable             = undef,
  String                               $logfile            = "${name}.log",
  String                               $logpath            = "/var/log/iocLogServer-${name}",
  Boolean                              $logrotate_compress = true,
  Integer                              $logrotate_rotate   = 30,
  String                               $logrotate_size     = '100M',
  Boolean                              $manage_user        = true,
  Integer[1, 65535]                    $port               = 7004,
  Array[String]                        $systemd_after      = [ 'network.target' ],
  Array[String]                        $systemd_requires   = [ 'network.target' ],
  Optional[Integer]                    $uid                = undef,
  String                               $username           = "ioclog-${name}",
)
{
  include 'epics_ioclogserver'

  systemd::unit_file { "iocLogServer-${name}.service":
    content => template("${module_name}/etc/systemd/system/iocLogServer.service"),
    notify  => Service["iocLogServer-${name}"],
  }

  if $manage_user {
    user { $username:
      comment => "${name} IOC",
      home    => "/epics/iocs/${name}",
      groups  => 'ioclogserver',
      uid     => $uid,
      before  => Service["iocLogServer-${name}"],
    }
  }

  file { $logpath:
    ensure => directory,
    owner  => $username,
    group  => 'ioclogserver',
    mode   => '2755',
  }

  logrotate::rule { "iocLogServer-${name}":
    path         => "${logpath}/${logfile}",
    rotate_every => 'day',
    compress     => $logrotate_compress,
    rotate       => $logrotate_rotate,
    size         => $logrotate_size,
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
      File[$logpath],
    ],
  }
}