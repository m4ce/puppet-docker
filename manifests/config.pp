class docker::config {
  if $docker::config_file_manage {
    File {
      owner  => 'root',
      group  => 'root',
      require => Package[keys($docker::packages)]
    }

    file {
      $docker::config_dir:
        mode   => '0700',
        ensure => 'directory';

      $docker::config_file:
        mode    => '0644',
        content => epp("docker/docker.json.epp", {
          'opts' => generate_json($docker::opts)
        })
    }

    if $docker::service_manage {
      File[$docker::config_file] {
        notify => Service[$docker::service_name]
      }
    }
  }
}
