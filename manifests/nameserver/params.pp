# = Class: pdns::nameserver::params
#
# This module manages pdns::nameserver
#
# == Parameters: none
#
# == Actions:
#
# == Requires: see Modulefile
#
# == Sample Usage:
#
class pdns::nameserver::params {
  case $::lsbdistcodename {
    'lenny', 'squeeze': {
      $hasstatus = false
      $checkstatus = "pgrep pdns_server"
    }
    default: {
      $hasstatus = true
      $checkstatus = undef
    }
  }
}
