class devechelon::reset {
  group { 'Management': ensure => absent } ->
  user { 'test':
    ensure   => absent,
    password => 'aTuO7A8/rDhzc',
    groups   => 'Management'
  }

  exec { 'reset':
    path    => '/usr/bin',
    command => 'yum -y erase java* apache* haproxy* mysql*'
  } ->
  exec { 'nuke':
    path    => '/bin',
    command => 'rm -rf /var/www/html /var/lib/mysql /etc/my.cnf /etc/apache*'
  }

}