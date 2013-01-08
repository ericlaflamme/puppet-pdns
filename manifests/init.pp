class pdns {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    Debian: { }
    default: {
      fail('This module only supports RedHat- and Debian-based systems')
    }
  }
  include pdns::nameserver
  include pdns::resolver
}
