class docker::lvm (
  String $vol_name,
  String $vol_group,
  String $vol_size,
  String $fs_type,
  Hash $fs_opts,
  Hash $mount_opts
) {
  logical_volume {$vol_name:
    ensure       => 'present',
    volume_group => $vol_group,
    size         => $vol_size
  }

  $device = "/dev/mapper/${vol_group}-${vol_name}"

  filesystem {$device:
    * => $fs_opts,
    fs_type => $fs_type,
    require => Logical_volume[$vol_name]
  }

  if 'data-root' in $docker::opts {
    $data_dir = $docker::opts['data-root']
  } else 'graph' in $docker::opts {
    $data_dir = $docker::opts['graph']
  } else {
    $data_dir = '/var/lib/docker'
  }

  mount {
    $data_dir:
      options => $mount_opts,
      device  => $device,
      fstype  => $fs_type,
      require => Filesystem[$device];

    default:
      ensure  => 'mounted',
      atboot  => true,
      options => 'defaults'
  }
}
