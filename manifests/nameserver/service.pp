class pdns::nameserver::service (
  $hasstatus = hiera('pdns::nameserver::hasstatus', $pdns::nameserver::params::hasstatus),
  $checkstatus = hiera('pdns::nameserver::checkstatus', $pdns::nameserver::params::checkstatus),
) inherits pdns::nameserver::params {
  service { 'pdns':
    ensure     => running,
    hasstatus  => $hasstatus,
    status     => $checkstatus,
    hasrestart => true,
    enable     => true,
    require    => Class['pdns::nameserver::config'],
  }
}
