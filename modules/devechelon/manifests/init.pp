class devechelon {
  group { 'Management': ensure => present } ->
  user { 'test':
    ensure   => present,
    password => 'aTuO7A8/rDhzc',
    groups   => 'Management'
  }

  class { 'java':
    distribution => 'oracle-jre',
    version      => '8'
  }

  class { 'apache':
  } ->
  apache::vhost { $::hostname:
    port    => '80',
    docroot => '/var/www/html',
  }

  class { '::mysql::server':
    root_password           => 'Mysql$$1234',
    remove_default_accounts => true,
    package_ensure          => '‎5.5.42'
  } ->
  mysql_database { "$::hostname/test":
    name    => 'test',
    charset => 'utf8',
  } ->
  mysql_user { 'test@test': password_hash => mysql_password('password'), } ->
  mysql_grant { "test@${::hostname}/test.*":
    table      => "test.*",
    user       => "test@${::hostname}",
    privileges => ['ALL'],
  }

  sudoers::allowed_command { "hooray":
    command          => "/var/www/html/hooray",
    user             => "apache",
    require_password => false
  } ->
  file { '/var/www/html/hooray':
    mode    => '0755',
    content => "#!/bin/bash \n echo 'Hooray for teamwork!'"
  }

  class { 'haproxy':
  } ->
  haproxy::balancermember { 'demo':
    listening_service => 'demo',
    server_names      => [$::fqdn],
    ipaddresses       => [$::ipaddress],
    ports             => '80',
    options           => 'check',
  } ->
  haproxy::listen { 'demo':
    mode      => 'tcp',
    ipaddress => $::ipaddress,
    ports     => '443',
    options   => {
      'option'  => ['tcplog'],
      'balance' => 'roundrobin',
      'log'     => 'global',
    }
    ,
  }

}