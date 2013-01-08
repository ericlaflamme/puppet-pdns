class pdns::resolver::service {
  case $::osfamily {
    RedHat: {
      service { 'pdns-recursor':
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        enable     => true,
        require    => Class['pdns::resolver::config'],
      }
    }
    Debian: {
      service { 'pdns-recursor':
        ensure     => running,
        hasstatus  => false,
        status     => "pgrep pdns_recursor",
        hasrestart => true,
        enable     => true,
        require    => Class['pdns::resolver::config'],
      }
    }
  }
}
