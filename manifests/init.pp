class docker (
  Docker::Images $images,
  Docker::Containers $containers,
  Docker::Networks $networks,
  Docker::Volumes $volumes,
  Docker::Options $opts,
  String $unix_socket,
  Boolean $data_on_lvm,
  String $config_dir,
  String $config_file,
  Boolean $config_file_manage,
  Hash $packages,
  String $service_name,
  Boolean $service_manage,
  Enum["stopped", "running"] $service_ensure,
  Boolean $service_enable
) {
  include docker::install
  include docker::config

  if $data_on_lvm {
    include docker::lvm
  }

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

  include docker::gc
}
