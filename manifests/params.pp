class etckeeper::params {
  # params
  $git_repo = undef
  $first_message = 'first commit'

  # os specific params
  case $::osfamily {
      'Debian': {
          $etckeeper_high_pkg_mgr = 'apt'
          $etckeeper_low_pkg_mgr = 'dpkg'
          $gitpackage = 'git-core'
          $etckeeper_package = 'etckeeper'
      }
      'RedHat': {
          $etckeeper_high_pkg_mgr = 'yum'
          $etckeeper_low_pkg_mgr = 'rpm'
          $gitpackage = 'git'
          $etckeeper_package = 'etckeeper'
      }
      default: {
          fail("etckeeper - Unsupported Operating System family: ${::osfamily}")
      }
  }
}