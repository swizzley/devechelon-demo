node /.*localhost*/ {
  include ::devechelon
}

node /^omd.*/ {
  include ::omd::server

  omd::site { 'default': config_hosts_folders => ['nodes'] }
}