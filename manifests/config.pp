class docker::config {
  if $docker::service_file_manage {
    # are we using docker-latest?

    if $docker::common_service_file != $docker::service_file {
      file {$docker::common_service_file:
        owner => "root",
        group => "root",
        mode => "0644",
        content => epp("docker/docker-common.sysconfig.epp"),
        require => Package[keys($docker::packages)]
      }
    }

    file {$docker::service_file:
      owner => "root",
      group => "root",
      mode => "0644",
      content => epp("docker/docker.sysconfig.epp"),
      require => Package[keys($docker::packages)]
    }

    if $docker::service_manage {
      File[$docker::service_file] {
        notify => Service[$docker::service_name]
      }
    }
  }
}
