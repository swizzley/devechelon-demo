class devechelon {
  include ::apache

  class { 'java':
    distribution => 'oracle-jre',
    version      => '8'
  }

  apache::vhost { $::hostname:
    port    => '80',
    docroot => '/var/www/html',
  }

  class { '::mysql::server':
    root_password           => 'root',
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
    command          => "/var/www/html/hooray.sh",
    user             => "apache",
    require_password => false
  } ->
  file { '/var/www/html/hooray.sh':
    mode    => '0755',
    content => "#!/bin/bash \n echo 'Hooray for teamwork!'"
  }

}