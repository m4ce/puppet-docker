class docker::gc::config {
  File {
    owner => "root",
    group => "root"
  }

  file {
    $docker::gc::config_dir:
      mode => '0755',
      ensure => "directory";

    $docker::gc::config_file:
      mode => '0644',
      content => epp('docker/docker-gc.conf.epp', {
        'opts' => $docker::gc::opts
      });

    "${docker::gc::config_dir}/exclude-images.conf":
      mode => '0644',
      content => epp('docker/gc-exclude.conf.epp', {
        'exclude' => $docker::gc::exclude_images
      });

    "${docker::gc::config_dir}/exclude-containers.conf":
      mode => '0644',
      content => epp('docker/gc-exclude.conf.epp', {
        'exclude' => $docker::gc::exclude_containers
      })
  }

  cron {'docker-gc':
    *       => $docker::gc::cron,
    command => "docker run --rm --env-file=${docker::gc::config_file} -v ${docker::gc::state_dir}:${docker::gc::state_dir}:rw -v ${docker::gc::config_dir}:${docker::gc::config_dir}:ro -v ${docker::unix_socket}:${docker::unix_socket} ${docker::gc::image_name}",
    user    => 'root',
    ensure  => $docker::gc::enable ? {
      true  => 'present',
      false => 'absent'
    },
    require => Docker_image[$docker::gc::image_name]
  }
}
