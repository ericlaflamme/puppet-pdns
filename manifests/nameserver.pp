# = Class: pdns::nameserver
#
# Installs and configures a PowerDNS nameserver - www.powerdns.com
#
# Currently supported backends: sqlite, postgresql, mysql
#
# Currently only supported on RedHat-based systems
#
# For more information see https://github.com/erwbgy/puppet-pdns/
class pdns::nameserver(
  $listen_address = $::ipaddress,
  $backend        = 'sqlite',
  $backend_host   = undef,
  $backend_port   = undef,
  $backend_user   = undef,
  $backend_password = undef,
  $backend_dbname = undef,
  $forward_domain = undef,
  $reverse_domain = undef,
  $use_hiera      = true
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    Debian: { }
    default: {
      fail('This module currently only supports RedHat- and Debian-based systems')
    }
  }
  if $use_hiera {
    $pdns = hiera_hash('pdns', undef)
    if $pdns {
      $nameserver = $pdns['nameserver']
      if $nameserver {
        class { 'pdns::nameserver::config':
          backend => $nameserver['backend'] ? {
            undef   => $backend,
            default => $nameserver['backend'],
          },
          backend_host => $nameserver['backend_host'] ? {
            undef   => $backend_host,
            default => $nameserver['backend_host'],
          },
          backend_port => $nameserver['backend_port'] ? {
            undef   => $backend_port,
            default => $nameserver['backend_port'],
          },
          backend_user => $nameserver['backend_user'] ? {
            undef   => $backend_user,
            default => $nameserver['backend_user'],
          },
          backend_password => $nameserver['backend_password'] ? {
            undef   => $backend_password,
            default => $nameserver['backend_password'],
          },
          backend_dbname => $nameserver['backend_dbname'] ? {
            undef   => $backend_dbname,
            default => $nameserver['backend_dbname'],
          },
          listen_address => $nameserver['listen_address'] ? {
            undef   => $listen_address,
            default => $nameserver['listen_address'],
          },
          forward_domain => $nameserver['forward_domain'] ? {
            undef   => $forward_domain,
            default => $nameserver['forward_domain'],
          },
          reverse_domain => $nameserver['reverse_domain'] ? {
            undef   => $reverse_domain,
            default => $nameserver['reverse_domain'],
          },
        }
        class { 'pdns::nameserver::install':
          backend        => $nameserver['backend'] ? {
            undef   => $backend,
            default => $nameserver['backend'],
          },
        }
        include pdns::nameserver::service
      }
    }
  }
  else {
    class { 'pdns::nameserver::config':
      backend        => $backend,
      backend_host   => $backend_host,
      backend_port   => $backend_port,
      backend_user   => $backend_user,
      backend_password  => $backend_password,
      backend_dbname => $backend_dbname,
      listen_address => $listen_address,
      forward_domain => $forward_domain,
      reverse_domain => $reverse_domain,
    }
    class { 'pdns::nameserver::install':
      backend        => $backend,
    }
    include pdns::nameserver::service
  }
}
