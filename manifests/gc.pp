class docker::gc (
  Docker::Gc::Options $opts,
  Array[String] $exclude_images,
  Array[String] $exclude_containers,
  String $state_dir,
  String $config_dir,
  String $image_name,
  Hash $cron,
  Boolean $enable
) {
  if $enable and empty($cron) {
    fail("Cron settings are required in ${title}")
  }

  include docker::gc::install
  include docker::gc::config
}
