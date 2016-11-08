class docker (
  Docker::Images $images,
  Docker::Containers $containers,
  Docker::Networks $networks,
  Docker::Volumes $volumes,
  Optional[Hash] $daemon_options,
  String $cert_path,
  Optional[Array] $add_registries,
  Optional[Array] $block_registries,
  Optional[Array] $insecure_registries,
  Optional[String] $tmpdir = undef,
  Optional[Boolean] $logrotate = undef,
  Optional[String] $bin_path = undef,
  String $service_file,
  Boolean $service_file_manage,
  Hash $packages,
  String $service_name,
  Boolean $service_manage,
  Enum["stopped", "running"] $service_ensure,
  Boolean $service_enable
) {
  include docker::install
  include docker::config
  include docker::storage
  include docker::service

  $images.each |String $k, Docker::Image $v| {
    docker_image {$k:
      * => $v
    }
  }

  $containers.each |String $k, Docker::Container $v| {
    docker_container {$k:
      * => $v
    }
  }

  $networks.each |String $k, Docker::Network $v| {
    docker_network {$k:
      * => $v
    }
  }

  $volumes.each |String $k, Docker::Volume $v| {
    docker_volume {$k:
      * => $v
    }
  }
}
