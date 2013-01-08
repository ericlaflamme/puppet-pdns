class pdns::nameserver::install (
  $backend = undef
) {
  case $::osfamily {
    RedHat: {
      $pdns_package = 'pdns'
      $pdns_sqlite3_package = 'pdns-backend-sqlite'
      $pdns_mysql_package = 'pdns-backend-mysq'
      $pdns_pgsql_package = 'pdns-backend-postgresql'
    }
    Debian: {
      $pdns_package = 'pdns-server'
      $pdns_sqlite3_package = 'pdns-backend-sqlite3'
      $pdns_mysql_package = 'pdns-backend-mysql'
      $pdns_pgsql_package = 'pdns-backend-pgsql'
    }
    default: {
      fail('This module currently only supports RedHat- and',
            'Debian-based systems')
    }
  }

  if $backend == undef {
    fail('pdns::nameserver::install backend parameter is required')
  }

  if ! defined(Package[$pdns_package]) {
    package { $pdns_package: ensure => installed }
  }

  case $backend {
    'postgresql': {
      if ! defined(Package[$pdns_pgsql_package]) {
        package { $pdns_pgsql_package: ensure => installed }
      }
    }
    'sqlite': {
      if ! defined(Package[$pdns_sqlite3_package]) {
        package { $pdns_sqlite3_package: ensure => installed }
      }
    }
    default: {
      fail("unknown backend - valid values are 'postgresql' or 'sqlite'")
    }
  }
}
