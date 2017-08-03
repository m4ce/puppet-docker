require 'securerandom'
require 'docker' if Puppet.features.docker_api?

Puppet::Type.type(:docker_container).provide(:docker_api) do
  desc "Manage Docker containers runtime"

  confine :feature => :docker_api

  # Use the docker unix socket for communicating with the daemon
  Docker.url = "unix:///var/run/docker.sock"

  def self.instances
    instances = []
    Docker::Container.all(:all => true).each do |container|
      # fetch more information about the container
      info = Docker::Container.get(container.id).info

      restart_policy = info['HostConfig']['RestartPolicy']['Name']
      restart_policy += ":#{info['HostConfig']['RestartPolicy']['MaximumRetryCount']}" if restart_policy == 'on-failure'

      instances << new(
        :id => container.id,
        :name => info['Name'].gsub(/^\//, ''),
        :image => info['Config']['Image'],
        :hostname => info['Config']['Hostname'],
        :domain_name => info['Config']['Domainname'],
        :user => info['Config']['User'],
        :attach_stdin => info['Config']['AttachStdin'] ? :true : :false,
        :attach_stdout => info['Config']['AttachStdout'] ? :true : :false,
        :attach_stderr => info['Config']['AttachStderr'] ? :true : :false,
        :tty => info['Config']['Tty'] ? :true : :false,
        :open_stdin => info['Config']['OpenStdin'] ? :true : :false,
        :stdin_once => info['Config']['StdinOnce'] ? :true : :false,
        :env => info['Config']['Env'],
        :cmd => info['Config']['Cmd'],
        :entrypoint => info['Config']['Entrypoint'],
        :labels => info['Config']['Labels'],
        :volumes => info['Config']['Volumes'],
        :network_disabled => info['Config']['NetworkDisabled'] ? :true : :false,
        :workdir => info['Config']['WorkingDir'],
        :exposed_ports => info['Config']['ExposedPorts'],
        :binds => info['HostConfig']['Binds'],
        :links => info['HostConfig']['Links'] ? info['HostConfig']['Links'].map { |x| x.gsub(/^\/(.+):\/.+\/(.+)$/, '\1:\2') } : nil,
        :blkio_weight => info['HostConfig']['BlkioWeight'],
        :blkio_weight_device => info['HostConfig']['BlkioWeightDevice'],
        :blkio_device_read_bps => info['HostConfig']['BlkioDeviceReadBps'],
        :blkio_device_write_bps => info['HostConfig']['BlkioDeviceWriteBps'],
        :blkio_device_read_iops => info['HostConfig']['BlkioDeviceReadIOps'],
        :blkio_device_write_iops => info['HostConfig']['BlkioDeviceWriteIOps'],
        :oom_kill_disable => info['HostConfig']['OomKillDisable'] ? :true : :false,
        :oom_score_adj => info['HostConfig']['OomScoreAdj'],
        :pid_mode => info['HostConfig']['PidMode'],
        :pids_limit => info['HostConfig']['PidsLimit'],
        :port_bindings => info['HostConfig']['PortBindings'],
        :publish_all_ports => info['HostConfig']['PublishAllPorts'] ? :true : :false,
        :privileged => info['HostConfig']['Privileged'] ? :true : :false,
        :readonly_rootfs => info['HostConfig']['ReadonlyRootfs'] ? :true : :false,
        :dns => info['HostConfig']['Dns'],
        :dns_search => info['HostConfig']['DnsSearch'],
        :dns_options => info['HostConfig']['DnsOptions'],
        :extra_hosts => info['HostConfig']['ExtraHosts'],
        :volumes_from => info['HostConfig']['VolumesFrom'],
        :cap_add => info['HostConfig']['CapAdd'],
        :cap_drop => info['HostConfig']['CapDrop'],
        :group_add => info['HostConfig']['GroupAdd'],
        :userns_mode => info['HostConfig']['UTSMode'],
        :network_mode => info['HostConfig']['NetworkMode'],
        :devices => info['HostConfig']['Devices'],
        :ulimits => info['HostConfig']['Ulimits'],
        :security_opt => info['HostConfig']['SecurityOpt'],
        :cgroup_parent => info['HostConfig']['CgroupParent'],
        :volume_driver => info['HostConfig']['VolumeDriver'],
        :shm_size => info['HostConfig']['ShmSize'],
        :log_driver => info['HostConfig']['LogConfig']['Type'],
        :log_opts => info['HostConfig']['LogConfig']['Config'],
        :cpu_shares => info['HostConfig']['CpuShares'],
        :cpu_period => info['HostConfig']['CpuPeriod'],
        :cpu_quota => info['HostConfig']['CpuQuota'],
        :cpuset_cpus => info['HostConfig']['CpusetCpus'],
        :cpuset_mems => info['HostConfig']['CpusetMems'],
        :memory => info['HostConfig']['Memory'],
        :memory_swap => info['HostConfig']['MemorySwap'],
        :memory_reservation => info['HostConfig']['MemoryReservation'],
        :kernel_memory => info['HostConfig']['KernelMemory'],
        :memory_swappiness => info['HostConfig']['MemorySwappiness'],
        :restart_policy => restart_policy,
        :ensure => (info['State']['Status'] == "running") ? :running : :stopped
      )
    end
    instances
  end

  def self.prefetch(resources)
    containers = instances
    resources.each do |name, resource|
      if provider = containers.find { |container| container.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present or @property_hash[:ensure] == :stopped or @property_hash[:ensure] == :running
  end

  def create
    # Prepare container configuration
    config = {}
    config['name'] = resource[:name]
    config['Image'] = resource[:image]
    config['Hostname'] = resource[:hostname] if resource[:hostname]
    config['Domainname'] = resource[:domain_name] if resource[:domain_name]
    config['User'] = resource[:user] if resource[:user]

    unless resource[:attach_stdin].nil?
      config['AttachStdin'] = resource[:attach_stdin] == :true ? true : false
    end

    unless resource[:attach_stdout].nil?
      config['AttachStdout'] = resource[:attach_stdout] == :true ? true : false
    end

    unless resource[:attach_stderr].nil?
      config['AttachStderr'] = resource[:attach_stderr] == :true ? true : false
    end

    unless resource[:tty].nil?
      config['Tty'] = resource[:tty] == :true ? true : false
    end

    unless resource[:open_stdin].nil?
      config['OpenStdin'] = resource[:open_stdin] == :true ? true : false
    end

    unless resource[:stdin_once].nil?
      config['StdinOnce'] = resource[:stdin_once] == :true ? true : false
    end

    config['Env'] = resource[:env] if resource[:env]
    config['Cmd'] = resource[:cmd] if resource[:cmd]
    config['Entrypoint'] = resource[:entrypoint] if resource[:entrypoint]
    config['Labels'] = resource[:labels] if resource[:labels]
    config['Volumes'] = resource[:volumes] if resource[:volumes]
    config['WorkingDir'] = resource[:workdir] if resource[:workdir]

    unless resource[:network_disabled].nil?
      config['NetworkDisabled'] = resource[:network_disabled] == :true ? true : false
    end

    config['ExposedPorts'] = resource[:exposed_ports] if resource[:exposed_ports]
    config['StopSignal'] = resource[:stop_signal] if resource[:stop_signal]

    config['HostConfig'] = {}
    config['HostConfig']['Binds'] = resource[:binds] if resource[:binds]
    config['HostConfig']['Links'] = resource[:links] if resource[:links]
    config['HostConfig']['Memory'] = resource[:memory] unless resource[:memory].nil?
    config['HostConfig']['MemorySwap'] = resource[:memory_swap] unless resource[:memory_swap].nil?
    config['HostConfig']['MemoryReservation'] = resource[:memory_reservation] unless resource[:memory_reservation].nil?
    config['HostConfig']['KernelMemory'] = resource[:kernel_memory] unless resource[:kernel_memory].nil?
    config['HostConfig']['CpuPercent'] = resource[:cpu_percent] unless resource[:cpu_percent].nil?
    config['HostConfig']['CpuShares'] = resource[:cpu_shares] unless resource[:cpu_shares].nil?
    config['HostConfig']['CpuPeriod'] = resource[:cpu_period] unless resource[:cpu_period].nil?
    config['HostConfig']['CpuQuota'] = resource[:cpu_quota] unless resource[:cpu_quota].nil?
    config['HostConfig']['CpusetCpus'] = resource[:cpuset_cpus] unless resource[:cpuset_cpus].nil?
    config['HostConfig']['CpusetMems'] = resource[:cpuset_mems] unless resource[:cpuset_mems].nil?
    config['HostConfig']['MaximumIOps'] = resource[:maximum_iops] unless resource[:maximum_iops].nil?
    config['HostConfig']['MaximumIOBps'] = resource[:maximum_iobps] unless resource[:maximum_iobps].nil?
    config['HostConfig']['BlkioWeight'] = resource[:blkio_weight] unless resource[:blkio_weight].nil?
    config['HostConfig']['BlkioWeightDevice'] = resource[:blkio_weight_device] if resource[:blkio_weight_device]
    config['HostConfig']['BlkioDeviceReadBps'] = resource[:blkio_device_read_bps] if resource[:blkio_device_read_bps]
    config['HostConfig']['BlkioDeviceReadIOps'] = resource[:blkio_device_read_iops] if resource[:blkio_device_read_iops]
    config['HostConfig']['BlkioDeviceWriteBps'] = resource[:blkio_device_write_bps] if resource[:blkio_device_write_bps]
    config['HostConfig']['BlkioDeviceWriteIOps'] = resource[:blkio_device_write_iops] if resource[:blkio_device_write_iops]
    config['HostConfig']['MemorySwappiness'] = resource[:memory_swappiness] unless resource[:memory_swappiness].nil?

    unless resource[:oom_kill_disable].nil?
      config['HostConfig']['OomKillDisable'] = resource[:oom_kill_disable] == :true ? true : false
    end

    config['HostConfig']['OomScoreAdj'] = resource[:oom_score_adj] unless resource[:oom_score_adj].nil?
    config['HostConfig']['PidMode'] = resource[:pid_mode] if resource[:pid_mode]
    config['HostConfig']['PidsLimit'] = resource[:pids_limit] unless resource[:pids_limit].nil?
    config['HostConfig']['PortBindings'] = resource[:port_bindings] if resource[:port_bindings]

    unless resource[:publish_all_ports].nil?
      config['HostConfig']['PublishAllPorts'] = resource[:publish_all_ports] == :true ? true : false
    end

    unless resource[:privileged].nil?
      config['HostConfig']['Privileged'] = resource[:privileged] == :true ? true : false
    end

    unless resource[:readonly_rootfs].nil?
      config['HostConfig']['ReadonlyRootfs'] = resource[:readonly_rootfs] == :true ? true : false
    end

    config['HostConfig']['Dns'] = resource[:dns] if resource[:dns]
    config['HostConfig']['DnsOptions'] = resource[:dns_options] if resource[:dns_options]
    config['HostConfig']['DnsSearch'] = resource[:dns_search] if resource[:dns_search]
    config['HostConfig']['ExtraHosts'] = resource[:extra_hosts] if resource[:extra_hosts]
    config['HostConfig']['VolumesFrom'] = resource[:volumes_from] if resource[:volumes_from]
    config['HostConfig']['CapAdd'] = resource[:cap_add] if resource[:cap_add]
    config['HostConfig']['CapDrop'] = resource[:cap_drop] if resource[:cap_drop]
    config['HostConfig']['GroupAdd'] = resource[:group_add] if resource[:group_add]

    if resource[:restart_policy]
      config['HostConfig']['RestartPolicy'] = {}

      name, max_retry_count = resource[:restart_policy].to_s.split(':')
      config['HostConfig']['RestartPolicy']['Name'] = name
      if name == 'on-failure'
        config['HostConfig']['RestartPolicy']['MaximumRetryCount'] = max_retry_count.to_i unless max_retry_count.nil?
      else
        config['HostConfig']['RestartPolicy']['MaximumRetryCount'] = 0
      end
    end

    config['HostConfig']['UsernsMode'] = resource[:userns_mode] if resource[:userns_mode]
    config['HostConfig']['NetworkMode'] = resource[:network_mode] if resource[:network_mode]
    config['HostConfig']['Devices'] = resource[:devices] if resource[:devices]
    config['HostConfig']['Ulimits'] = resource[:ulimits] if resource[:ulimits]

    if resource[:log_driver]
      config['HostConfig']['LogConfig'] = {}
      config['HostConfig']['LogConfig']['Type'] = resource[:log_driver]
      config['HostConfig']['LogConfig']['Config'] = resource[:log_opts] if resource[:log_opts]
    end

    config['HostConfig']['SecurityOpt'] = resource[:security_opt] if resource[:security_opt]
    config['HostConfig']['StorageOpt'] = resource[:storage_opt] if resource[:storage_opt]
    config['HostConfig']['CgroupParent'] = resource[:cgroup_parent] if resource[:cgroup_parent]
    config['HostConfig']['VolumeDriver'] = resource[:volume_driver] if resource[:volume_driver]
    config['HostConfig']['ShmSize'] = resource[:shm_size] unless resource[:shm_size].nil?

    begin
      container = Docker::Container.create(config)
    rescue
      raise Puppet::Error, "Could not create container #{self.name}: #{$!}"
    end

    container.start if resource[:ensure] == :running
    @property_hash[:ensure] = resource[:ensure]
    @property_hash[:id] = container.id
  end

  def status
    if @property_hash.empty?
      :absent
    else
      if resource[:ensure] == :present
        :present
      else
        @property_hash[:ensure]
      end
    end
  end

  def start
    unless @property_hash.empty?
      container = Docker::Container.get(@property_hash[:id])
      container.start
    else
      self.create
    end
  end

  def stop
    self.create if @property_hash.empty?
    container = Docker::Container.get(@property_hash[:id])
    container.stop
  end

  def destroy
    container = Docker::Container.get(@property_hash[:id])

    # stop container first
    container.stop if @property_hash[:ensure] == :running

    container.delete(:force => true)
    @property_hash.clear
  end

  def restart
    container = Docker::Container.get(@property_hash[:id])
    container.restart
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
    @recreate = false
  end

  def image=(value)
    @recreate = true
    @property_hash[:image] = value
  end

  def hostname=(value)
    @recreate = true
    @property_hash[:hostname] = value
  end

  def domain_name=(value)
    @recreate = true
    @property_hash[:domain_name] = value
  end

  def user=(value)
    @recreate = true
    @property_hash[:user] = value
  end

  def attach_stdin=(value)
    @recreate = true
    @property_hash[:attach_stdin] = value
  end

  def attach_stdout=(value)
    @recreate = true
    @property_hash[:attach_stdout] = value
  end

  def attach_stderr=(value)
    @recreate = true
    @property_hash[:attach_stderr] = value
  end

  def tty=(value)
    @recreate = true
    @property_hash[:tty] = value
  end

  def open_stdin=(value)
    @recreate = true
    @property_hash[:open_stdin] = value
  end

  def stdin_once=(value)
    @recreate = true
    @property_hash[:stdin_once] = value
  end

  def env=(value)
    @recreate = true
    @property_hash[:env] = value
  end

  def cmd=(value)
    @recreate = true
    @property_hash[:cmd] = value
  end

  def entrypoint=(value)
    @recreate = true
    @property_hash[:entrypoint] = value
  end

  def labels=(value)
    @recreate = true
    @property_hash[:labels] = value
  end

  def volumes=(value)
    @recreate = true
    @property_hash[:volumes] = value
  end

  def network_disabled=(value)
    @recreate = true
    @property_hash[:network_disabled] = value
  end

  def workdir=(value)
    @recreate = true
    @property_hash[:workdir] = value
  end

  def exposed_ports=(value)
    @recreate = true
    @property_hash[:exposed_ports] = value
  end

  def binds=(value)
    @recreate = true
    @property_hash[:binds] = value
  end

  def links=(value)
    @recreate = true
    @property_hash[:links] = value
  end

  def blkio_weight_device=(value)
    @recreate = true
    @property_hash[:blkio_weight_device] = value
  end

  def blkio_device_read_bps=(value)
    @recreate = true
    @property_hash[:blkio_device_read_bps] = value
  end

  def blkio_device_write_bps=(value)
    @recreate = true
    @property_hash[:blkio_device_write_bps] = value
  end

  def blkio_device_read_iops=(value)
    @recreate = true
    @property_hash[:blkio_device_read_iops] = value
  end

  def blkio_device_write_iops=(value)
    @recreate = true
    @property_hash[:blkio_device_write_iops] = value
  end

  def oom_kill_disable=(value)
    @recreate = true
    @property_hash[:oom_kill_disable] = value
  end

  def oom_score_adj=(value)
    @recreate = true
    @property_hash[:oom_score_adj] = value
  end

  def pid_mode=(value)
    @recreate = true
    @property_hash[:pid_mode] = value
  end

  def pids_limit=(value)
    @recreate = true
    @property_hash[:pids_limit] = value
  end

  def port_bindings=(value)
    @recreate = true
    @property_hash[:port_bindings] = value
  end

  def publish_all_ports=(value)
    @recreate = true
    @property_hash[:publish_all_ports] = value
  end

  def privileged=(value)
    @recreate = true
    @property_hash[:privileged] = value
  end

  def readonly_rootfs=(value)
    @recreate = true
    @property_hash[:readonly_rootfs] = value
  end

  def dns=(value)
    @recreate = true
    @property_hash[:dns] = value
  end

  def dns_search=(value)
    @recreate = true
    @property_hash[:dns_search] = value
  end

  def dns_options=(value)
    @recreate = true
    @property_hash[:dns_options] = value
  end

  def extra_hosts=(value)
    @recreate = true
    @property_hash[:extra_hosts] = value
  end

  def volumes_from=(value)
    @recreate = true
    @property_hash[:volumes_from] = value
  end

  def cap_add=(value)
    @recreate = true
    @property_hash[:cap_add] = value
  end

  def cap_drop=(value)
    @recreate = true
    @property_hash[:cap_drop] = value
  end

  def group_add=(value)
    @recreate = true
    @property_hash[:group_add] = value
  end

  def userns_mode=(value)
    @recreate = true
    @property_hash[:userns_mode] = value
  end

  def network_mode=(value)
    @recreate = true
    @property_hash[:network_mode] = value
  end

  def devices=(value)
    @recreate = true
    @property_hash[:devices] = value
  end

  def ulimits=(value)
    @recreate = true
    @property_hash[:ulimits] = value
  end

  def security_opt=(value)
    @recreate = true
    @property_hash[:security_opt] = value
  end

  def cgroup_parent=(value)
    @recreate = true
    @property_hash[:cgroup_parent] = value
  end

  def volume_driver=(value)
    @recreate = true
    @property_hash[:volume_driver] = value
  end

  def shm_size=(value)
    @recreate = true
    @property_hash[:shm_size] = value
  end

  def log_driver=(value)
    @recreate = true
    @property_hash[:log_driver] = value
  end

  def log_opts=(value)
    @recreate = true
    @property_hash[:log_opts] = value
  end

  def blkio_weight=(value)
    @property_hash[:blkio_weight] = value
    @property_flush['BlkioWeight'] = value
  end

  def cpu_shares=(value)
    @property_hash[:cpu_shares] = value
    @property_flush['CpuShares'] = value
  end

  def cpu_period=(value)
    @property_hash[:cpu_period] = value
    @property_flush['CpuPeriod'] = value
  end

  def cpu_quota=(value)
    @property_hash[:cpu_quota] = value
    @property_flush['CpuQuota'] = value
  end

  def cpuset_cpus=(value)
    @property_hash[:cpuset_cpus] = value
    @property_flush['CpusetCpus'] = value
  end

  def cpuset_mems=(value)
    @property_hash[:cpuset_mems] = value
    @property_flush['CpusetMems'] = value
  end

  def memory=(value)
    @property_hash[:memory] = value
    @property_flush['Memory'] = value
  end

  def memory_swap=(value)
    @property_hash[:memory_swap] = value
    @property_flush['MemorySwap'] = value
  end

  def memory_reservation=(value)
    @property_hash[:memory_reservation] = value
    @property_flush['MemoryReservation'] = value
  end

  def kernel_memory=(value)
    @property_hash[:kernel_memory] = value
    @property_flush['KernelMemory'] = value
  end

  def restart_policy=(value)
    @property_hash[:restart_policy] = value

    name, max_retry_count = value.to_s.split(':')
    @property_flush['RestartPolicy'] = {}
    @property_flush['RestartPolicy']['Name'] = name
    if name == 'on-failure'
      @property_flush['RestartPolicy']['MaximumRetryCount'] = max_retry_count.to_i unless max_retry_count.nil?
    else
      @property_flush['RestartPolicy']['MaximumRetryCount'] = 0
    end
  end

  def flush
    if @property_hash.has_key?(:id)
      container = Docker::Container.get(@property_hash[:id])
      if @recreate
        container.stop(:timeout => 30)
        if resource[:remove_on_change]
          Puppet.warning("Removing container #{resource[:name]} (ID: #{@property_hash[:id]})")
          container.delete(:force => true)
        else
          uuid = SecureRandom.uuid
          Puppet.debug("Renaming container #{resource[:name]} (ID: #{@property_hash[:id]}) to #{uuid}")
          container.rename(uuid)
        end
        Puppet.debug("Re-creating container #{resource[:name]}")
        create
      else
        unless @property_flush.empty?
          container.update(@property_flush)
        end
      end
    end
  end
end
