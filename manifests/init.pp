# This class takes care of all global task which are needed in order to run an
# EPICS IOC log server.
#
class epics_ioclogserver {
  package { 'epics-dev':
    ensure => latest,
  }
}
