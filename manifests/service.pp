class docker::service {
  if $docker::service_manage {
    service {$docker::service_name:
      ensure => $docker::service_ensure,
      enable => $docker::service_enable,
      subscribe => Package[keys($docker::packages)]
    }
  }
}
