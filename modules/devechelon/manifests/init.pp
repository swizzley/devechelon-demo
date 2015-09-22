class devechelon {
  group { 'Management': ensure => present } ->
  user { 'demo':
    ensure   => present,
    password => 'aTuO7A8/rDhzc',
    groups   => 'Management'
  }

  class { 'java':
    distribution => 'jdk',
    version      => '8'
  } ->
  exec { "java_home":
    path    => '/bin:/usr/bin',
    command => 'echo "export JAVA_HOME=$(readlink -f $(which java)|rev|cut -c 10-|rev)" > /etc/profile.d/java_home.sh',
    unless  => 'grep JAVA_HOME /etc/profile.d/*',
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
  } ->
  mysql::db { 'demo':
    user     => 'demo',
    password => 'demo',
    host     => 'localhost',
    grant    => ['ALL'],
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
  }
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
