class docker::gc (
  Docker::Gc::Options $opts,
  Array[String] $exclude_images,
  Array[String] $exclude_containers,
  String $state_dir,
  String $log_file,
  String $config_dir,
  String $config_file,
  String $image_name,
  Hash $cron,
  Boolean $enable
) {
  if $enable and empty($cron) {
    fail("Cron settings are required in ${title}")
  }

  if $enable {
    include docker::gc::install
    include docker::gc::config

    Cron['docker-gc'] {
      ensure => 'present',
      require => Docker_image[$image_name]
    }
  } else {
    Cron['docker-gc'] {
      ensure => 'absent'
    }
  }

  cron {'docker-gc':
    *       => $cron,
    command => "docker run --rm --env-file=${config_file} -v ${state_dir}:${state_dir}:rw -v ${config_dir}:${config_dir}:ro -v ${docker::unix_socket}:${docker::unix_socket} ${image_name} >${log_file}",
    user    => 'root'
  }
}
