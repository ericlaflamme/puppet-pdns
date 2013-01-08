class pdns::nameserver::config (
  $backend        = 'sqlite',
  $listen_address = $::ipaddress,
  $forward_domain = undef,
  $reverse_domain = undef
) {
  if $backend == undef {
    fail('pdns::nameserver::config backend parameter is required')
  }
  if $listen_address == undef {
    fail('pdns::nameserver::config listen_address parameter is required')
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
    owner => 'pdns',
    group => 'pdns',
  }
  file { '/etc/pdns/pdns.conf':
    ensure  => present,
    mode    => '0400',
    content => template('pdns/nameserver/pdns.conf.erb'),
    require => Package['pdns'],
    notify  => Class['pdns::nameserver::service'],
  }
}
