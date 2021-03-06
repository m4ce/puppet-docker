type Docker::Container = Struct[{
  image => String,
  Optional[ensure] => Enum["present", "running", "stopped", "absent"],
  Optional[hostname] => String,
  Optional[domain_name] => String,
  Optional[user] => String,
  Optional[attach_stdin] => Boolean,
  Optional[attach_stdout] => Boolean,
  Optional[attach_stderr] => Boolean,
  Optional[tty] => Boolean,
  Optional[open_stdin] => Boolean,
  Optional[stdin_once] => Boolean,
  Optional[env] => Array[Pattern[/^\w+=.*$/]],
  Optional[cmd] => Variant[String, Array[String]],
  Optional[entrypoint] => Variant[String, Array[String]],
  Optional[labels] => Hash,
  Optional[volumes] => Hash,
  Optional[workdir] => String,
  Optional[network_disabled] => Boolean,
  Optional[exposed_ports] => Hash[Pattern[/^\d+\/(tcp|udp)$/], Struct[{}]],
  Optional[stop_signal] => Variant[String, Integer],
  Optional[binds] => Array[Pattern[/^[\w\/]+:[\w\/]+(:(rw|ro))?$/]],
  Optional[links] => Array[Pattern[/^\w+:\w+$/]],
  Optional[memory] => Integer[0],
  Optional[memory_swap] => Integer[-1],
  Optional[memory_reservation] => Integer[0],
  Optional[kernel_memory] => Integer[0],
  Optional[cpu_percent] => Integer[0],
  Optional[cpu_shares] => Integer[0],
  Optional[cpu_period] => Integer[0],
  Optional[cpu_quota] => Integer[0],
  Optional[cpuset_cpus] => String,
  Optional[cpuset_mems] => String,
  Optional[maximum_iops] => Integer[0],
  Optional[maximum_iobps] => Integer[0],
  Optional[blkio_weight] => Integer[10, 1000],
  Optional[blkio_weight_device] => Array[Struct[{'Path' => String, 'Weight' => Integer[0]}]],
  Optional[blkio_device_read_bps] => Array[Struct[{'Path' => String, 'Rate' => Integer[0]}]],
  Optional[blkio_device_write_bps] => Array[Struct[{'Path' => String, 'Rate' => Integer[0]}]],
  Optional[blkio_device_read_iops] => Array[Struct[{'Path' => String, 'Rate' => Integer[0]}]],
  Optional[blkio_device_write_iops] => Array[Struct[{'Path' => String, 'Rate' => Integer[0]}]],
  Optional[memory_swappiness] => Integer[0, 100],
  Optional[oom_kill_disable] => Boolean,
  Optional[oom_score_adj] => Integer[-1000, 1000],
  Optional[pid_mode] => Variant[Enum["host"], Pattern[/^container:(\w+)$/]],
  Optional[pids_limit] => Integer[-1],
  Optional[port_bindings] => Hash[Pattern[/^\d+\/(tcp|udp)$/], Array[Struct[{'HostPort' => Pattern[/^\d+$/]}]]],
  Optional[publish_all_ports] => Boolean,
  Optional[privileged] => Boolean,
  Optional[readonly_rootfs] => Boolean,
  Optional[dns] => Array[String],
  Optional[dns_search] => Array[String],
  Optional[extra_hosts] => Array[Pattern[/^.+:(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/]],
  Optional[volumes_from] => Array[Pattern[/^.+(:(rw|ro))?/]],
  Optional[cap_add] => Array[String],
  Optional[cap_drop] => Array[String],
  Optional[group_add] => Array[String],
  Optional[restart_policy] => Variant[Enum['always', 'unless-stopped'], Pattern[/^on-failure(:\d+)?$/]],
  Optional[network_mode] => Variant[Enum['bridge', 'none', 'host'], Pattern[/^container:(\w+)$/, /./]],
  Optional[devices] => Array[Struct[{'PathOnHost' => String, 'PathInContainer' => String, 'CgroupPermissions' => Enum['ro', 'rw']}]],
  Optional[ulimits] => Array[Struct[{'Name' => String, 'Soft' => Integer, 'Hard' => Integer}]],
  Optional[sysctls] => Hash,
  Optional[security_opt] => Array[String],
  Optional[storage_opt] => Hash,
  Optional[log_driver] => Enum['json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'awslogs', 'splunk', 'etwlogs', 'none', 'json-file'],
  Optional[log_opts] => Hash,
  Optional[cgroup_parent] => String,
  Optional[volume_driver] => String,
  Optional[shm_size] => Integer[0],
}]
