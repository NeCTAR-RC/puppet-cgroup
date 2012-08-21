class cgroup {

  package {
    'cgroup-bin':
      ensure => present;
  }

  # There is no ensure running because it takes ages to run and this
  # only needs to be run once.
  service {
    'cgconfig':
      enable     => true,
      hasrestart => false,
      require    => Package['cgroup-bin'];
    'cgred':
      enable     => true,
      hasrestart => false,
      require    => Package['cgroup-bin'];
  }

  file {
    '/etc/cgconfig.conf':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('cgroup/cgconfig.erb'),
      require => Package['cgroup-bin'],
      notify  => Service['cgconfig'];
    '/etc/cgrules.conf':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => 'puppet:///modules/cgroup/cgrules.conf',
      require => Package['cgroup-bin'],
      notify  => Service['cgred'];
  }

  file {
    "/lib/modules/${::kernelrelease}/russell.ko":
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/cgroup/russell.ko';
  }

  exec {
    'depmod_russell':
      command     => 'depmod -a',
      subscribe   => File["/lib/modules/${::kernelrelease}/russell.ko"],
      refreshonly => true,
      path        => ['/usr/bin', '/usr/sbin'];
    'modprobe_russell':
      command     => 'modprobe russell',
      subscribe   => Exec['depmod_russell'],
      refreshonly => true,
      path        => ['/usr/bin', '/usr/sbin'];
  }

  common::line {
    'mod_russell':
      ensure => 'present',
      file   => '/etc/modules',
      line   => 'russell';
  }
}
