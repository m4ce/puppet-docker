class docker::gc::config {
  File {
    owner => "root",
    group => "root"
  }

  $exclude_images_file = "${docker::gc::config_dir}/exclude-images.conf"
  $exclude_containers_file = "${docker::gc::config_dir}/exclude-containers.conf"

  file {
    $docker::gc::config_dir:
      mode => '0755',
      ensure => "directory";

    $docker::gc::config_file:
      mode => '0644',
      content => epp('docker/docker-gc.conf.epp', {
        'opts' => merge($docker::gc::opts, {
          'exclude_from_gc' => $exclude_images_file,
          'exclude_containers_from_gc' => $exclude_containers_file
        })
      });

    $exclude_images_file:
      mode => '0644',
      content => epp('docker/gc-exclude.conf.epp', {
        'exclude' => $docker::gc::exclude_images
      });

    $exclude_containers_file:
      mode => '0644',
      content => epp('docker/gc-exclude.conf.epp', {
        'exclude' => $docker::gc::exclude_containers
      })
  }
}
