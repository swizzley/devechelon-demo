class devechelon {
  exec { "firewall_off": command => '/sbin/service iptables stop', }
  group { 'Management': ensure => present } ->
  user { 'demo':
    ensure   => present,
    password => 'aTuO7A8/rDhzc',
    groups   => 'Management'
  }

  class { 'java':
    distribution => 'jdk',
    version      => 'latest'
  } ->
  exec { "java_home":
    path    => '/bin:/usr/bin',
    command => 'echo "export JAVA_HOME=$(readlink -f $(which java)|rev|cut -c 10-|rev)" > /etc/profile.d/java_home.sh',
    unless  => 'grep JAVA_HOME /etc/profile.d/*',
  }

  class { 'apache':
  } ->
  class { 'apache::php': } ->
  apache::vhost { $::hostname:
    port    => '80',
    docroot => '/var/www/html',
  }

  class { '::mysql::server':
    root_password           => 'Mysql$$1234',
    remove_default_accounts => false,
  } ->
  mysql::db { 'demo':
    user     => 'demo',
    password => 'demo',
    host     => '0.0.0.0',
    grant    => ['ALL'],
  } ->
  mysql_grant { 'demo@localhost/demo.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'ALL'],
    table      => 'demo.*',
    user       => 'demo@puppet',
  }

  exec { 'bind-all':
    path    => '/bin',
    command => "sed -i s/'127.0.0.1'/'0.0.0.0'/g /etc/my.cnf",
    unless  => 'grep 0.0.0.0 /etc/my.cnf'
  }

  sudoers::allowed_command { "hooray":
    command          => "/var/www/html/hooray.sh",
    user             => "apache",
    require_password => false
  } ->
  file { '/var/www/html/hooray.php':
    mode    => '0755',
    owner   => 'apache',
    group   => 'apache',
    content => "<?php
   \$outcome = shell_exec('/var/www/html/hooray.sh');
   echo \$outcome;
?>"
  } ->
  file { '/var/www/html/hooray.sh':
    mode    => '0755',
    owner   => 'apache',
    group   => 'apache',
    content => "#!/bin/bash
    echo \"my name is $(hostname) and Hooray for teamwork!\""
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

