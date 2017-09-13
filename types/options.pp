type Docker::Options = Struct[{
  Optional['add-runtime']                      => String,
  Optional['allow-nondistributable-artifacts'] => Array[String],
  Optional['api-cors-header']                  => String,
  Optional['authorization-plugin']             => Array[String],
  Optional['bip']                              => String,
  Optional['bridge']                           => String,
  Optional['cgroup-parent']                    => String,
  Optional['cluster-advertise']                => String,
  Optional['cluster-store']                    => String,
  Optional['cluster-store-opt']                => Hash,
  Optional['containerd']                       => String,
  Optional['cpu-rt-period']                    => Integer,
  Optional['cpu-rt-runtime']                   => Integer,
  Optional['data-root']                        => String,
  Optional['debug']                            => Boolean,
  Optional['default-gateway']                  => String,
  Optional['default-gateway-v6']               => String,
  Optional['default-runtime']                  => String,
  Optional['default-ulimit']                   => Array[String],
  Optional['disable-legacy-registry']          => Boolean,
  Optional['dns']                              => Array[String],
  Optional['dns-opt']                          => Array[String],
  Optional['dns-search']                       => Array[String],
  Optional['exec-opt']                         => Array[String],
  Optional['exec-root']                        => String,
  Optional['experimental']                     => Boolean,
  Optional['fixed-cidr']                       => String,
  Optional['fixed-cidr-v6']                    => String,
  Optional['group']                            => String,
  Optional['host']                             => Array[String],
  Optional['icc']                              => Boolean,
  Optional['init']                             => Boolean,
  Optional['init-path']                        => String,
  Optional['insecure-registry']                => Array[String],
  Optional['ip']                               => String,
  Optional['ip-forward']                       => Boolean,
  Optional['ip-masq']                          => Boolean,
  Optional['iptables']                         => Boolean,
  Optional['ipv6']                             => Boolean,
  Optional['label']                            => Array[String],
  Optional['live-restore']                     => Boolean,
  Optional['log-driver']                       => Enum['none', 'json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'awslogs', 'splunk', 'etwlogs', 'gcplogs'],
  Optional['log-level']                        => Enum['debug', 'info', 'warn', 'error', 'fatal'],
  Optional['log-opt']                          => Hash,
  Optional['max-concurrent-downloads']         => Integer,
  Optional['max-concurrent-uploads']           => Integer,
  Optional['metrics-addr']                     => String,
  Optional['mtu']                              => Integer,
  Optional['no-new-privileges']                => Boolean,
  Optional['oom-score-adjust']                 => Integer,
  Optional['pidfile']                          => String,
  Optional['raw-logs']                         => Boolean,
  Optional['registry-mirror']                  => Array[String],
  Optional['seccomp-profile']                  => String,
  Optional['selinux-enabled']                  => Boolean,
  Optional['shutdown-timeout']                 => Integer,
  Optional['storage-driver']                   => Enum['overlay', 'overlay2', 'aufs', 'devicemapper', 'btrfs', 'zfs'],
  Optional['storage-opt']                      => Array[String],
  Optional['swarm-default-advertise-addr']     => String,
  Optional['tls']                              => Boolean,
  Optional['tlscacert']                        => String,
  Optional['tlscert']                          => String,
  Optional['tlskey']                           => String,
  Optional['tlsverify']                        => Boolean,
  Optional['userland-proxy']                   => Boolean,
  Optional['userland-proxy-path']              => String,
  Optional['userns-remap']                     => String
}]