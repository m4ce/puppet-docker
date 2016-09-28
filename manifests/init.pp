class docker (
  Docker::Images $images,
  Docker::Containers $containers,
  Optional[Hash] $daemon_options,
  String $cert_path,
  Optional[Array] $add_registries,
  Optional[Array] $block_registries,
  Optional[Array] $insecure_registries,
  Optional[String] $tmpdir = undef,
  Optional[Boolean] $logrotate = undef,
  Optional[String] $bin_path = undef,
  String $cli_path,
  String $service_file,
  Boolean $service_file_manage,
  String $package_name,
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
}
