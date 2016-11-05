#
# docker_api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.type(:docker_container).provide(:docker_api) do
  desc "Manage Docker containers runtime"

  confine :feature => :docker_api
  require 'docker'

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
        :blkio_weight => info['HostConfig']['BlkioWeight'],
        :cpu_shares => info['HostConfig']['CpuShares'],
        :cpu_period => info['HostConfig']['CpuPeriod'],
        :cpu_quota => info['HostConfig']['CpuQuota'],
        :cpuset_cpus => info['HostConfig']['CpusetCpus'],
        :cpuset_mems => info['HostConfig']['CpusetMems'],
        :memory => info['HostConfig']['Memory'],
        :memory_swap => info['HostConfig']['MemorySwap'],
        :memory_reservation => info['HostConfig']['MemoryReservation'],
        :kernel_memory => info['HostConfig']['KernelMemory'],
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
    config['HostConfig']['Memory'] = resource[:memory] if resource[:memory]
    config['HostConfig']['MemorySwap'] = resource[:memory_swap] if resource[:memory_swap]
    config['HostConfig']['MemoryReservation'] = resource[:memory_reservation] if resource[:memory_reservation]
    config['HostConfig']['KernelMemory'] = resource[:kernel_memory] if resource[:kernel_memory]
    config['HostConfig']['CpuPercent'] = resource[:cpu_percent] if resource[:cpu_percent]
    config['HostConfig']['CpuShares'] = resource[:cpu_shares] if resource[:cpu_shares]
    config['HostConfig']['CpuPeriod'] = resource[:cpu_period] if resource[:cpu_period]
    config['HostConfig']['CpuQuota'] = resource[:cpu_quota] if resource[:cpu_quota]
    config['HostConfig']['CpusetCpus'] = resource[:cpuset_cpus] if resource[:cpuset_cpus]
    config['HostConfig']['CpusetMems'] = resource[:cpuset_mems] if resource[:cpuset_mems]
    config['HostConfig']['MaximumIOps'] = resource[:maximum_iops] if resource[:maximum_iops]
    config['HostConfig']['MaximumIOBps'] = resource[:maximum_iobps] if resource[:maximum_iobps]
    config['HostConfig']['BlkioWeightDevice'] = resource[:blkio_weight_device] if resource[:blkio_weight_device]
    config['HostConfig']['BlkioDeviceReadBps'] = resource[:blkio_device_read_bps] if resource[:blkio_device_read_bps]
    config['HostConfig']['BlkioDeviceReadIOps'] = resource[:blkio_device_read_iops] if resource[:blkio_device_read_iops]
    config['HostConfig']['BlkioDeviceWriteBps'] = resource[:blkio_device_write_bps] if resource[:blkio_device_write_bps]
    config['HostConfig']['BlkioDeviceWriteIOps'] = resource[:blkio_device_write_iops] if resource[:blkio_device_write_iops]
    config['HostConfig']['MemorySwappiness'] = resource[:memory_swappiness] if resource[:memory_swappiness]

    unless resource[:oom_kill_disable].nil?
      config['HostConfig']['OomKillDisable'] = resource[:oom_kill_disable] == :true ? true : false
    end

    config['HostConfig']['OomScoreAdj'] = resource[:oom_score_adj] if resource[:oom_score_adj]
    config['HostConfig']['PidMode'] = resource[:pid_mode] if resource[:pid_mode]
    config['HostConfig']['PidsLimit'] = resource[:pids_limit] if resource[:pids_limit]
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

      name, max_retry_count = resource[:restart_policy].split(':')
      config['HostConfig']['RestartPolicy']['Name'] = name
      config['HostConfig']['RestartPolicy']['MaximumRetryCount'] = max_retry_count unless max_retry_count.nil?
    end

    config['HostConfig']['UsernsMode'] = resource[:userns_mode] if resource[:userns_mode]
    config['HostConfig']['NetworkMode'] = resource[:network_mode] if resource[:network_mode]
    config['HostConfig']['Devices'] = resource[:devices] if resource[:devices]
    config['HostConfig']['Ulimits'] = resource[:ulimits] if resource[:ulimits]

    if resource[:log_driver]
      config['HostConfig']['LogConfig'] = {}
      config['HostConfig']['LogConfig']['Type'] = resource[:log_driver]
      config['HostConfig']['LogConfig']['Config'] = resource[:logs_opts] if resource[:log_opts]
    end

    config['HostConfig']['SecurityOpt'] = resource[:security_opt] if resource[:security_opt]
    config['HostConfig']['StorageOpt'] = resource[:storage_opt] if resource[:storage_opt]
    config['HostConfig']['CgroupParent'] = resource[:cgroup_parent] if resource[:cgroup_parent]
    config['HostConfig']['VolumeDriver'] = resource[:volume_driver] if resource[:volume_driver]
    config['HostConfig']['ShmSize'] = resource[:shm_size] if resource[:shm_size]

    begin
      container = Docker::Container.create(config)
    rescue
      raise Puppet::Error, "Could not create container #{self.name}: #{$!}"
    end

    container.start if resource[:ensure] == :running
    @property_hash[:ensure] = resource[:ensure]
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
  end

  def blkio_weight=(value)
    @property_flush['BlkioWeight'] = value
  end

  def cpu_shares=(value)
    @property_flush['CpuShares'] = value
  end

  def cpu_period=(value)
    @property_flush['CpuPeriod'] = value
  end

  def cpu_quota=(value)
    @property_flushp['CpuQuota'] = value
  end

  def cpuset_cpus=(value)
    @property_flush['CpusetCpus'] = value
  end

  def cpuset_mems=(value)
    @property_flush['CpusetMems'] = value
  end

  def memory=(value)
    @property_flush['Memory'] = value
  end

  def memory_swap=(value)
    @property_flush['MemorySwap'] = value
  end

  def memory_reservation=(value)
    @property_flush['MemoryReservation'] = value
  end

  def kernel_memory=(value)
    @property_flush['KernelMemory'] = value
  end

  def restart_policy=(value)
    name, max_retry_count = value.split(':')
    @property_flush['RestartPolicy']['Name'] = name
    @property_flush['RestartPolicy']['MaximumRetryCount'] = max_retry_count unless max_retry_count.nil?
  end

  def flush
    unless @property_flush.empty?
      container = Docker::Container.get(@property_hash[:id])
      container.update(@property_flush)
    end
  end
end
