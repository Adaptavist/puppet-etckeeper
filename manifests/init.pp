class etckeeper(
  $git_repo               = $etckeeper::params::git_repo,
  $first_message          = $etckeeper::params::first_message,
  $etckeeper_high_pkg_mgr = $etckeeper::params::etckeeper_high_pkg_mgr,
  $etckeeper_low_pkg_mgr  = $etckeeper::params::etckeeper_low_pkg_mgr,
  $gitpackage             = $etckeeper::params::gitpackage,
  $etckeeper_package      = $etckeeper::params::etckeeper_package,
  ) inherits etckeeper::params {

  include noconfigpkgs::git

  package { $etckeeper_package:
      ensure => 'installed',
  }

  file { '/etc/etckeeper':
    ensure => directory,
    mode   => '0755',
  }

  file { 'etckeeper.conf':
    ensure  => present,
    path    => '/etc/etckeeper/etckeeper.conf',
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/etckeeper.conf.erb"),
  }

  exec { 'etckeeper-init':
    command => 'etckeeper init',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd     => '/etc',
    creates => '/etc/.git',
    require => [ Package[$gitpackage], Package[$etckeeper_package] ],
  }

  file {'/etc/etckeeper/commit.d/60-push' :
          ensure  => file,
          content => inline_template("#!/bin/sh\ngit push -q origin master:\$(hostname -s)\n"),
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          require => [Exec[etckeeper-init]],
  }

  # finally install and initiallize etckeeper to track our changes
  exec {'add_remote_repo' :
          command   => "etckeeper vcs remote add origin ${git_repo}",
          logoutput => on_failure,
          unless    => "etckeeper vcs config --get remote.origin.url == ${git_repo}",
          require   => File['/etc/etckeeper/commit.d/60-push'],
  }
  exec {'make_first_commit' :
          command   => "etckeeper commit -m \"${first_message}\" > /dev/null",
          logoutput => on_failure,
          require   => Exec['add_remote_repo'],
  }

}
