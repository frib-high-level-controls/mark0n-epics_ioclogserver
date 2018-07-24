# This class takes care of all global task which are needed in order to run an
# EPICS IOC log server.
#
class epics_ioclogserver(
  Optional[Integer] $gid = undef,
) {
  package { 'ioclogserver':
    ensure => latest,
  }

  group { 'ioclogserver':
    ensure => present,
    gid    => $gid,
  }
}
