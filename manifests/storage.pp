class docker::storage (
  Enum["", "devicemapper", "overlay"] $driver,
  Optional[String] $extra_options = undef,
  Optional[String] $vg = undef,
  Optional[Array] $devs = undef,
  Optional[String] $root_size = undef,
  Optional[String] $data_size = undef,
  Optional[String] $min_data_size = undef,
  Optional[String] $chunk_size = undef,
  Optional[String] $growpart = undef,
  Optional[Boolean] $auto_extend_pool = undef,
  Optional[Integer] $pool_autoextend_threshold = undef,
  Optional[Integer] $pool_autoextend_percent = undef,
  String $config_file,
  Boolean $config_file_manage
) {
  case $driver {
    "devicemapper": {
      if ! $vg or ! size($devs) > 0 {
        fail("Must pass either a volume group or a list of devices when storage driver is devicemapper in ${title}")
      }
    }
  }

  if $config_file_manage {
    file {$config_file:
      owner => "root",
      group => "root",
      mode => "0644",
      content => epp("docker/docker-storage-setup.sysconfig.epp"),
      require => Package[keys($docker::packages)]
    }

    if $docker::service_manage {
      File[$config_file] {
        notify => Service["docker"]
      }
    }
  }
}

