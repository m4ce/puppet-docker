class docker::config {
  if $docker::service_file_manage {
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
