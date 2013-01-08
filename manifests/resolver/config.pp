class pdns::resolver::config (
  $listen_address = $::ipaddress,
  $dont_query     = undef,
  $forward_zones  = [],
  $forward_domain = undef,
  $reverse_domain = undef,
  $nameservers    = $::ipaddress,
  $additional_config = {}
) {
  case $::osfamily {
    RedHat: {
      $recursor_conf = '/etc/pdns-recursor/recursor.conf'
      $forward_zones_file = '/etc/pdns-recursor/forward_zones'
      $user = 'pdns-recursor'
      $group = 'pdns-recursor'
    }
    Debian: {
      $recursor_conf = '/etc/powerdns/recursor.conf'
      $forward_zones_file = '/etc/powerdns/forward_zones'
      $user = 'pdns'
      $group = 'pdns'
    }
  }

  if $forward_domain {
    # By default the pdns recursor will not send queries to local addresses
    # but if we are running a local domain then we need to change this to
    # enable queries to our name server
    if $dont_query == undef {
      case $nameservers {
        /^10\./:  { $_dont_query = '127.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128' }
        /^172\./: { $_dont_query = '127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, ::1/128' }
        /^192\./: { $_dont_query = '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128' }
        /^127\./: { $_dont_query = '10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128' }
        default:  { $_dont_query = undef }
      }
    }
    else {
      $_dont_query = $dont_query
    }

    # Set the reverse domain based on the first nameserver IP address
    if $reverse_domain {
      $_reverse_domain = $reverse_domain
    }
    else {
      case $nameservers {
        /^127\./: { $_reverse_domain = '127.in-addr.arpa' }
        /^10\./:  { $_reverse_domain = '10.in-addr.arpa' }
        /^172\./: { $_reverse_domain = '16.172.in-addr.arpa' }
        /^192\./: { $_reverse_domain = '168.192.in-addr.arpa' }
        default: {
          fail('pdns::resolver::config forward_domain is set but reverse_domain is not and must be')
        }
      }
      warning("setting reverse_domain to ${_reverse_domain} based on the first nameserver IP address in ${nameservers}")
    }
    $_forward_zones = [
      "${forward_domain}=${nameservers}",
      "${_reverse_domain}=${nameservers}"
    ]
  }
  else {
    $_dont_query    = $dont_query
    $_forward_zones = $forward_zones
  }

  # defaults
  File {
    owner => $user,
    group => $group,
  }
  file { $recursor_conf:
    ensure  => present,
    mode    => '0444',
    content => template('pdns/resolver/recursor.conf.erb'),
    require => Package['pdns-recursor'],
    notify  => Class['pdns::resolver::service'],
  }
  file { $forward_zones_file:
    ensure  => present,
    mode    => '0444',
    content => template('pdns/resolver/forward_zones.erb'),
    require => Package['pdns-recursor'],
    notify  => Class['pdns::resolver::service'],
  }
}
