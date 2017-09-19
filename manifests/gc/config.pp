class docker::gc::config {
  File {
    owner => "root",
    group => "root"
  }

  file {
    $docker::gc::config_dir:
      mode => '0755',
      ensure => "directory";

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
    command => "docker run --rm -e GRACE_PERIOD_SECONDS=${docker::gc::grace_period_seconds} -e FORCE_CONTAINER_REMOVAL=${Integer($docker::gc::force_container_removal)} -e FORCE_IMAGE_REMOVAL=${Integer($docker::gc::force_image_removal)} -e MINIMUM_IMAGE_TO_SAVE=${docker::gc::minimum_image_to_save} -v ${docker::gc::state_dir}:${docker::gc::state_dir}:rw -v ${docker::gc::config_dir}:${docker::gc::config_dir}:ro ${docker::gc::image_name}",
    user    => 'root',
    ensure  => $docker::gc::enable ? {
      true  => 'present',
      false => 'absent'
    },
    require => Docker_image[$docker::gc::image_name]
  }
}
