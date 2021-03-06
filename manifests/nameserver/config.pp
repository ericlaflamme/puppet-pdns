class pdns::nameserver::config (
  $backend        = 'sqlite',
  $backend_host   = undef,
  $backend_port   = undef,
  $backend_user   = undef,
  $backend_password = undef,
  $backend_dbname = undef,
  $listen_address = $::ipaddress,
  $additional_config = {},
  $forward_domain = undef,
  $reverse_domain = undef
) {
  case $::osfamily {
    RedHat: {
      $pdns_package = 'pdns-server'
      $pdns_conf = '/etc/pdns/pdns.conf'
      $user = 'pdns'
      $group = 'pdns'
      if $backend_dbname and $backend == 'sqlite' {
        $sqlite_file = $backend_dbname
      }
      else {
        $sqlite_file = '/var/pdns/powerdns.sqlite'
      }
    }
    Debian: {
      $pdns_package = 'pdns-server'
      $pdns_conf = '/etc/powerdns/pdns.conf'
      $user = 'pdns'
      $group = 'pdns'
      if $backend_dbname and $backend == 'sqlite' {
        $sqlite_file = $backend_dbname
      }
      else {
        $sqlite_file = '/var/lib/powerdns/pdns.sqlite3'
      }
    }
    default: {
      fail('This module currently only supports RedHat- and',
            'Debian-based systems')
    }
  }

  if $backend == undef {
    fail('pdns::nameserver::config backend parameter is required')
  }
  if $listen_address == undef {
    fail('pdns::nameserver::config listen_address parameter is required')
  }

  case $backend {
    postgresql: { $backend_module = 'gpgsql' }
    mysql:      { $backend_module = 'gmysql' }
    sqlite:     { $backend_module = 'gsqlite3' }
  }

  # Set the reverse domain based on the current IP address
  if $reverse_domain {
    $reverse = $reverse_domain
  }
  if $forward_domain and !$reverse_domain {
    case $listen_address {
      /^127\./: { $reverse = '127.in-addr.arpa' }
      /^10\./:  { $reverse = '10.in-addr.arpa' }
      /^172\./: { $reverse = '16.172.in-addr.arpa' }
      /^192\./: { $reverse = '168.192.in-addr.arpa' }
      default: {
        err("listen_address is ${listen_address}")
        err("::ipaddress is ${::ipaddress}")
        fail('pdns::nameserver::config forward_domain is set but reverse_domain is not and must be')
      }
    }
    notify { "setting reverse_domain to ${reverse} based on IP address ${::ipaddress}": }
  }

  # defaults
  File {
    owner => $user,
    group => $group,
  }
  file { $pdns_conf:
    ensure  => present,
    mode    => '0400',
    content => template('pdns/nameserver/pdns.conf.erb'),
    require => Package[$pdns_package],
    notify  => Class['pdns::nameserver::service'],
  }
}
