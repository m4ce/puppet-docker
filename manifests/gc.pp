class docker::gc (
  Array[String] $exclude_images,
  Array[String] $exclude_containers,
  Integer $grace_period_seconds,
  Boolean $force_image_removal,
  Boolean $force_container_removal,
  String $state_dir,
  String $config_dir,
  String $service_image,
  Hash $cron,
  Boolean $enable
) {
  if $enable and empty($cron) {
    fail("Cron settings are required in ${title}")
  }

  include docker::gc::install
  include docker::gc::config
}
