#
# docker_container.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.newtype(:docker_container) do
  @doc = 'Manage Docker container(s) runtime'

  ensurable do
    desc 'Whether the container should be running or not'
    defaultvalues

    newvalue(:running) do
      provider.start
    end

    newvalue(:stopped) do
      provider.stop
    end

    def retrieve
      provider.status
    end

    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'Container name'
  end

  newparam(:image) do
    desc 'A string specifying the image name to use for the container'

    validate do
      raise ArgumentError, "Docker image is required for container #{self[:name]}" unless self[:image]
    end
  end

  newparam(:hostname) do
    desc "Container hostname"
  end

  newparam(:domain_name) do
    desc "Container domain name"
  end

  newparam(:user) do
    desc "A string value specifying the user inside the container."
  end

  newparam(:attach_stdin, :boolean => true) do
    desc 'Boolean value, attaches to stdin'
    newvalues(:true, :false)
  end

  newparam(:attach_stdout, :boolean => true) do
    desc 'Boolean value, attaches to stdout'
    newvalues(:true, :false)
  end

  newparam(:attach_stderr, :boolean => true) do
    desc 'Boolean value, attaches to stderr.'
    newvalues(:true, :false)
  end

  newparam(:tty, :boolean => true) do
    desc 'Boolean value, Attach standard streams to a tty, including stdin if it is not closed.'
    newvalues(:true, :false)
  end

  newparam(:open_stdin, :boolean => true) do
    desc 'Boolean value, opens stdin'
    newvalues(:true, :false)
  end

  newparam(:stdin_once, :boolean => true) do
    desc 'Boolean value, close stdin after the 1 attached client disconnects'
    newvalues(:true, :false)
  end

  newparam(:env) do
    desc 'A list of environment variables in the form of ["VAR=value"[,"VAR2=value2"]]'

    validate do |value|
      raise ArgumentError, "#{value} is not an Array" unless value.is_a?(Array)

      value.each do |env|
        if env !~ /^\w+=.*$/
          raise ArgumentError, "Container environment variable '#{env}' is not in the form of VAR=value"
        end
      end
    end
  end

  newparam(:cmd) do
    desc "Command to run specified as a string or an array of strings"

    validate do |value|
      raise ArgumentError, "Container command '#{value}' must be either a String or an Array" unless value.is_a?(String) or value.is_a?(Array)
    end
  end

  newparam(:entrypoint) do
    desc "Set the entry point for the container as a string or an array of strings"

    validate do |value|
      raise ArgumentError, "Container entrypoint #{value} must be either a String or an Array" unless value.is_a?(String) or value.is_a?(Array)
    end
  end

  newparam(:labels) do
    desc 'Adds a map of labels to a container. To specify a map: {"key" => "value"[,"key2" => "value2"]}'

    validate do |value|
      raise ArgumentError, "Container labels '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:volumes) do
    desc "An object mapping mount point paths (strings) inside the container to empty objects."

    validate do |value|
      raise ArgumentError, "Container volumes '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:workdir) do
    desc "A string specifying the working directory for commands to run in"
  end

  newparam(:network_disabled, :boolean => true) do
    desc "A string specifying the working directory for commands to run in"
    newvalues(:true, :false)
  end

  newparam(:exposed_ports) do
    desc "An object mapping ports to an empty object in the form of: <port>/<tcp|udp>: {}"

    validate do |value|
      raise ArgumentError, "#{value} is not a Hash" unless value.is_a?(Hash)

      value.keys.each do |k|
        if k !~ /^\d+\/(tcp|udp)$/
          raise ArgumentError, "Container exposed port '#{k}' must be in the form of <port>/<tcp|udp>"
        end
      end
    end
  end

  newparam(:stop_signal) do
    desc "Signal to stop a container as a string or unsigned integer"
  end

  newparam(:binds) do
    desc "A list of volume bindings for this container"

    validate do |value|
      raise ArgumentError, "#{value} is not an Array" unless value.is_a?(Array)

      value.each do |v|
        if v !~ /^[\w\/]+:[\w\/]+(:(rw|ro))?$/
          raise ArgumentError, "Container volume bind '#{v}' is not in the form of <host_path>:<container_path>[:<ro|rw>]"
        end
      end
    end
  end

  newparam(:links) do
    desc "A list of links for the container. Each link entry should be in the form of container_name:alias"

    validate do |value|
      raise ArgumentError, "#{value} is not an Array" unless value.is_a?(Array)

        if v !~ /^\w+:\w+$/
          raise ArgumentError, "Container link '#{v}' is not in the form of <container_name>:<alias>"
        end
    end
  end

  newproperty(:memory) do
    desc "Memory limit in bytes"

    validate do |value|
      raise ArgumentError, "Container memory limit '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:memory_swap) do
    desc "Total memory limit (memory + swap); set -1 to enable unlimited swap. You must use this with memory and make the swap value larger than memory."

    validate do |value|
      raise ArgumentError, "Container memory swap limit '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:memory_reservation) do
    desc "Memory soft limit in bytes"

    validate do |value|
      raise ArgumentError, "Container memory reservation '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:kernel_memory) do
    desc "Kernel memory limit in bytes"

    validate do |value|
      raise ArgumentError, "Container kernel memory '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newparam(:cpu_percent) do
    desc "An integer value containing the usable percentage of the available CPUs"

    validate do |value|
      raise ArgumentError, "Container CPU percentage '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:cpu_shares) do
    desc "An integer value containing the container’s CPU Shares (ie. the relative weight vs other containers)."

    validate do |value|
      raise ArgumentError, "Container CPU shares '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:cpu_period) do
    desc "The length of a CPU period in microseconds"

    validate do |value|
      raise ArgumentError, "Container CPU period '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:cpu_quota) do
    desc "Microseconds of CPU time that the container can get in a CPU period"

    validate do |value|
      raise ArgumentError, "Container CPU quota '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:cpuset_cpus) do
    desc "String value containing the cgroups CpusetCpus to use"
  end

  newproperty(:cpuset_mems) do
    desc "Memory nodes (MEMs) in which to allow execution (0-3, 0,1). Only effective on NUMA systems"
  end

  newparam(:maximum_iops) do
    desc "Maximum IO absolute rate in terms of IOps"

    validate do |value|
      raise ArgumentError, "Container maximum IOPS '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newparam(:maximum_iobps) do
    desc "Maximum IO absolute rate in terms of bytes per second."

    validate do |value|
      raise ArgumentError, "Container maximum IObps '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newproperty(:blkio_weight) do
    desc "Block IO weight (relative weight) accepts a weight value between 10 and 1000"

    validate do |value|
      raise ArgumentError, "Container block IO weight '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  newparam(:blkio_weight_device) do
    desc 'Block IO weight (relative device weight) in the form of [{"Path" => "device_path", "Weight" => weight}]'

    validate do |value|
      raise ArgumentError, "Container block IO device weight '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:blkio_device_read_bps) do
    desc "Limit read rate (bytes per second) from a device"

    validate do |value|
      raise ArgumentError, "Container device read rate Bps limit '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:blkio_device_write_bps) do
    desc "Limit write rate (bytes per second) to a device"

    validate do |value|
      raise ArgumentError, "Container device write rate Bps limit '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:blkio_device_read_iops) do
    desc "Limit read rate (IO per second) from a device"

    validate do |value|
      raise ArgumentError, "Container device read rate IOPS limit '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:blkio_device_write_iops) do
    desc "Limit write rate (IO per second) to a device"

    validate do |value|
      raise ArgumentError, "Container device write rate IOPS limit '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newproperty(:memory_swappiness) do
    desc "Tune a container’s memory swappiness behavior. Accepts an integer between 0 and 100."

    validate do |value|
      raise ArgumentError, "Container memory swappiness '#{value}' is not an Integer" unless value.is_a?(Array)
    end
  end

  newparam(:oom_kill_disable, :boolean => true) do
    desc "Whether to disable OOM Killer for the container or not."
    newvalues(:true, :false)
  end

  newparam(:oom_score_adj) do
    desc "Tune container’s OOM preferences (-1000 to 1000)"

    validate do |value|
      raise ArgumentError, "Container OOM score '#{value}' is not an Integer" unless value.is_a?(Array)
    end
  end

  newparam(:pid_mode) do
    desc "Set the PID (Process) Namespace mode for the container"
    newvalues('host', /^container:(\w+)$/)
  end

  newparam(:pids_limit) do
    desc "Tune a container’s pids limit. Set -1 for unlimited"

    validate do |value|
      raise ArgumentError, "Container PIDs limit '#{value}' is not an Integer" unless value.is_a?(Array)
    end
  end

  newparam(:port_bindings) do
    desc "A map of exposed container ports and the host port they should map to"

    validate do |value|
      raise ArgumentError, "Container port bindings '#{value}' is not a Hash" unless value.is_a?(Hash)

      value.each do |k, v|
        if k !~ /^\d+\/(tcp|udp)$/
          raise ArgumentError, "Container port binding '#{k}' must be in the form of <port>/<tcp|udp>"
        end

        raise ArgumentError, "Container port binding host port '#{v}' is not an Array" unless v.is_a?(Array)
      end
    end
  end

  newparam(:publish_all_ports, :boolean => true) do
    desc "Allocates a random host port for all of a container’s exposed ports"
    newvalues(:true, :false)
  end

  newparam(:privileged, :boolean => true) do
    desc "Gives the container full access to the host"
    newvalues(:true, :false)
  end

  newparam(:readonly_rootfs, :boolean => true) do
    desc "Mount the container’s root filesystem as read only"
    newvalues(:true, :false)
  end

  newparam(:dns) do
    desc "A list of DNS servers for the container to use"

    validate do |value|
      raise ArgumentError, "Container DNS servers '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:dns_options) do
    desc "A list of DNS options"

    validate do |value|
      raise ArgumentError, "Container DNS options '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:dns_search) do
    desc "A list of DNS search domains"

    validate do |value|
      raise ArgumentError, "Container DNS search '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:extra_hosts) do
    desc 'A list of hostnames/IP mappings to add to the container’s /etc/hosts file. Specified in the form ["hostname:IP"].'

    validate do |value|
      raise ArgumentError, "Container hostnames/IP mappings '#{value}' is not an Array" unless value.is_a?(Array)

      value.each do |v|
        if v !~ /^.+:(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
          raise ArgumentError, "Container port binding '#{k}' must be in the form of <hostname>:<ip>"
        end
      end
    end
  end

  newparam(:volumes_from) do
    desc "A list of volumes to inherit from another container. Specified in the form <container name>[:<ro|rw>]"

    validate do |value|
      raise ArgumentError, "Container volumes from  '#{value}' is not an Array" unless value.is_a?(Array)

      value.each do |v|
        if v !~ /^.+(:(rw|ro))?/
          raise ArgumentError, "Container port binding '#{k}' must be in the form of <hostname>:<ip>"
        end
      end
    end
  end

  newparam(:cap_add) do
    desc "A list of kernel capabilities to add to the container"

    validate do |value|
      raise ArgumentError, "Container add capabilities  '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:cap_drop) do
    desc "A list of kernel capabilities to drop from the container"

    validate do |value|
      raise ArgumentError, "Container drop capabilities  '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:group_add) do
    desc 'A list of additional groups that the container process will run as'

    validate do |value|
      raise ArgumentError, "Container additional groups  '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newproperty(:restart_policy) do
    desc 'The behavior to apply when the container exits'
    newvalues(/^on-failure(:\d+)?$/, 'always', 'unless-stopped')
  end

  newparam(:userns_mode) do
    desc 'Sets the usernamespace mode for the container when usernamespace remapping option is enabled'
    newvalues('host')
  end

  newparam(:network_mode) do
    desc 'Sets the networking mode for the container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network’s name to which this container should connect to.'
    newvalues('bridge', 'none', 'host', /^container:(\w+)$/, /./)
  end

  newparam(:devices) do
    desc 'A list of devices to add to the container specified in the form {"PathOnHost" => "/dev/deviceName", "PathInContainer" => "/dev/deviceName", "CgroupPermissions" => "mrw"}'

    validate do |value|
      raise ArgumentError, "Container devices '#{value}' is not an Array" unless value.is_a?(Array)

      value.each do |k, v|
        raise ArgumentError, "Container device '#{v}' is not a Hash" unless v.is_a?(Hash)
      end
    end
  end

  newparam(:ulimits) do
    desc 'A list of ulimits to set in the container, specified as {"Name" => <name>, "Soft" => <soft limit>, "Hard" => <hard limit> }'

    validate do |value|
      raise ArgumentError, "Container ulimits '#{value}' is not an Array" unless value.is_a?(Array)

      value.each do |k, v|
        raise ArgumentError, "Container ulimit '#{v}' is not a Hash" unless v.is_a?(Hash)
      end
    end
  end

  newparam(:sysctls) do
    desc 'A list of kernel parameters (sysctls) to set in the container, specified as {<name> => <Value> }, for example: {"net.ipv4.ip_forward" => ""}'

    validate do |value|
      raise ArgumentError, "Container sysctls '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:security_opt) do
    desc 'A list of string values to customize labels for MLS systems, such as SELinux'

    validate do |value|
      raise ArgumentError, "Container security options '#{value}' is not an Array" unless value.is_a?(Array)
    end
  end

  newparam(:storage_opt) do
    desc 'Storage driver options per container. Options can be passed in the form {"size" => "120G"}'

    validate do |value|
      raise ArgumentError, "Container security options '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:log_driver) do
    desc 'Log driver for the container'
    newvalues('json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'awslogs', 'splunk', 'etwlogs', 'none', 'json-file')
  end

  newparam(:log_opts) do
    desc 'Log driver options for the container'

    validate do |value|
      raise ArgumentError, "Log driver options '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:cgroup_parent) do
    desc 'Path to cgroups under which the container’s cgroup is created. If the path is not absolute, the path is considered to be relative to the cgroups path of the init process. Cgroups are created if they do not already exist.'
  end

  newparam(:volume_driver) do
    desc 'Driver that this container users to mount volumes'
  end

  newparam(:shm_size) do
    desc 'Size of /dev/shm in bytes. The size must be greater than 0.'

    validate do |value|
      raise ArgumentError, "Container shared memory size '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  autorequire(:service) do
    ["docker"]
  end

  autorequire(:docker_image) do
    self[:image]
  end
end
