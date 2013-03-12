class mirebalais_logging::kibana(
  $mysql_master_ip = hiera('mysql_master_ip')
  ) {

  file { 'kibana_config':
    ensure  => 'present',
    path    => '/usr/local/kibana/KibanaConfig.rb',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('mirebalais_logging/KibanaConfig.rb.erb'),
    notify  => Service['kibana'],
    require => [ File['/usr/local/kibana'], Exec['kibana-unzip'] ]
  }

  service { 'kibana':
    ensure  => running,
    enable  => true,
    require => [ File['kibana_config'], File['/etc/init.d/kibana'] ]
  }

  file { '/etc/init.d/kibana':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/mirebalais_logging/etc/init.d/kibana'
  }

  file {'/usr/local/kibana':
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }

  wget::fetch { 'download-kibana':
    source      => 'https://github.com/rashidkpc/Kibana/archive/v0.2.0.tar.gz',
    destination => '/usr/local/kibana_0.2.0.tgz',
    timeout     => 0,
    verbose     => false,
  }

  exec { 'kibana-unzip':
    cwd     => '/usr/local',
    command => 'tar -C kibana --strip-components=1 -xzf /usr/local/kibana_0.2.0.tgz',
    unless  => 'test -f /usr/local/kibana/kibana.rb',
    require => [ Package['tar'], Wget::Fetch['download-kibana'], File['/usr/local/kibana'] ],
  }

}
