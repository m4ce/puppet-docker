#
# docker_container.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.newtype(:docker_container) do
  @doc = 'Manage Docker container(s) runtime'

  feature :refreshable, "The provider can restart the container.", :methods => [:restart]

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

  newproperty(:hostname) do
    desc "Container hostname"
  end

  newparam(:remove_on_change, :boolean => true) do
    desc 'Boolean value, remove container when changing non runtime parameters, else renames it'
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:image) do
    desc 'A string specifying the image name to use for the container'
  end

  validate do
    raise ArgumentError, "Docker image is required for container #{self[:name]}" unless self[:image]
  end

  newproperty(:domain_name) do
    desc "Container domain name"
  end

  newproperty(:user) do
    desc "A string value specifying the user inside the container."
  end

  newproperty(:attach_stdin, :boolean => true) do
    desc 'Boolean value, attaches to stdin'
    newvalues(:true, :false)
  end

  newproperty(:attach_stdout, :boolean => true) do
    desc 'Boolean value, attaches to stdout'
    newvalues(:true, :false)
  end

  newproperty(:attach_stderr, :boolean => true) do
    desc 'Boolean value, attaches to stderr.'
    newvalues(:true, :false)
  end

  newproperty(:tty, :boolean => true) do
    desc 'Boolean value, Attach standard streams to a tty, including stdin if it is not closed.'
    newvalues(:true, :false)
  end

  newproperty(:open_stdin, :boolean => true) do
    desc 'Boolean value, opens stdin'
    newvalues(:true, :false)
  end

  newproperty(:stdin_once, :boolean => true) do
    desc 'Boolean value, close stdin after the 1 attached client disconnects'
    newvalues(:true, :false)
  end

  newproperty(:env, :array_matching => :all) do
    desc 'A list of environment variables in the form of ["VAR=value"[,"VAR2=value2"]]'

    validate do |value|
      if value !~ /^\w+=.*$/
        raise ArgumentError, "Container environment variable '#{value}' is not in the form of VAR=value"
      end
    end

    def insync?(current)
      return false if current == :absent

      cur = {}
      current.map { |x| x.split('=', 2) }.each do |k, v|
        cur[k] = v
      end

      new = {}
      @should.map { |x| x.split('=', 2) }.each do |k, v|
        new[k] = v
      end

      new.each do |k, v|
        if cur.keys.include?(k)
          return false unless cur[k] == v
        else
          return false
        end
      end

      true
    end

    def should
      return nil unless @should

      members = @should

      current = provider.env
      if current != :absent
        cur = {}
        current.map { |x| x.split('=', 2) }.each do |k, v|
          cur[k] = v
        end

        new = {}
        @should.map { |x| x.split('=', 2) }.each do |k, v|
          new[k] = v
        end

        members = cur.merge(new).map { |k, v| "#{k}=#{v}" }
      end

      members
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:cmd, :array_matching => :all) do
    desc "Command to run specified as a string or an array of strings"

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:entrypoint, :array_matching => :all) do
    desc "Set the entry point for the container as a string or an array of strings"

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:labels) do
    desc 'Adds a map of labels to a container. To specify a map: {"key" => "value"[,"key2" => "value2"]}'

    validate do |value|
      raise ArgumentError, "Container labels '#{value}' is not a Hash" unless value.is_a?(Hash)
    end

    def insync?(current)
      return false if current == :absent

      @should.first.each do |k, v|
        if current.keys.include?(k)
          return false unless current[k] == v
        else
          return false
        end
      end

      true
    end

    def should
      return nil unless @should
      members = @should.first

      current = provider.labels
      if current != :absent
        members = current.merge(members)
      end

      members
    end
  end

  newproperty(:volumes) do
    desc "An object mapping mount point paths (strings) inside the container to empty objects."

    validate do |value|
      raise ArgumentError, "Container volumes '#{value}' is not a Hash" unless value.is_a?(Hash)
    end

    def insync?(current)
      return false if current == :absent
      @should.first.each do |k, v|
        return false unless current.keys.include?(k)
      end

      true
    end

    def should
      return nil unless @should
      members = @should.first

      current = provider.volumes
      if current != :absent
        members = current.merge(members)
      end

      members
    end
  end

  newproperty(:workdir) do
    desc "A string specifying the working directory for commands to run in"
  end

  newproperty(:network_disabled, :boolean => true) do
    desc "A string specifying the working directory for commands to run in"
    newvalues(:true, :false)
  end

  newproperty(:exposed_ports) do
    desc 'An object mapping ports to an empty object in the form of: "<port>/<tcp|udp>" => {}'

    validate do |value|
      raise ArgumentError, "#{value} is not a Hash" unless value.is_a?(Hash)

      value.keys.each do |k|
        if k !~ /^\d+\/(tcp|udp)$/
          raise ArgumentError, "Container exposed port '#{k}' must be in the form of <port>/<tcp|udp>"
        end
      end
    end

    def insync?(current)
      return false if current == :absent
      @should.first.each do |k, v|
        return false unless current.keys.include?(k)
      end

      true
    end

    def should
      return nil unless @should
      members = @should.first

      current = provider.exposed_ports
      if current != :absent
        members = current.merge(members)
      end

      members
    end
  end

  newparam(:stop_signal) do
    desc "Signal to stop a container as a string or unsigned integer"
  end

  newproperty(:binds, :array_matching => :all) do
    desc "A list of volume bindings for this container. Each volume binding is a string in one of these forms:
 * host-src:container-dest to bind-mount a host path into the container. Both host-src, and container-dest must be an absolute path.
 * host-src:container-dest:ro to make the bind-mount read-only inside the container. Both host-src, and container-dest must be an absolute path.
 * volume-name:container-dest to bind-mount a volume managed by a volume driver into the container. container-dest must be an absolute path.
 * volume-name:container-dest:ro to mount the volume read-only inside the container. container-dest must be an absolute path."

    validate do |value|
      if value !~ /^.+:.+:r[wo]$/
        raise ArgumentError, "Container volume bind '#{value}' is not in the form of <host_path>:<container_path>:<ro|rw>"
      end
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:links, :array_matching => :all) do
    desc "A list of links for the container. Each link entry should be in the form of <container_name>:<alias>"

    validate do |value|
      if value !~ /^\w+:\w+$/
        raise ArgumentError, "Container link '#{value}' is not in the form of <container_name>:<alias>"
      end
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
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
    desc "An integer value containing the container's CPU Shares (ie. the relative weight vs other containers)."

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
      raise ArgumentError, "Container block IO weight '#{value}' must be between 10 and 1000" unless (value >= 10 and value <= 1000)
    end
  end

  newproperty(:blkio_weight_device, :array_matching => :all) do
    desc 'Block IO weight (relative device weight) in the form of [{"Path" => "device_path", "Weight" => weight}]'

    validate do |value|
      raise ArgumentError, "Missing 'Path' in Block IO weight device" unless value.has_key?('Path')
      raise ArgumentError, "Missing 'Weight' in Block IO weight device" unless value.has_key?('Weight')
      raise ArgumentError, "'Weight' parameter must be an Integer in Block IO weight device" unless value['Weight'].is_a?(Integer)
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:blkio_device_read_bps, :array_matching => :all) do
    desc 'Limit read rate (bytes per second) from a device in the form of: [{"Path" => "device_path", "Rate" => rate}]'

    validate do |value|
      raise ArgumentError, "Missing 'Path' in Block IO read rate Bps device" unless value.has_key?('Path')
      raise ArgumentError, "Missing 'Rate' in Block IO read rate Bps device" unless value.has_key?('Rate')
      raise ArgumentError, "'Rate' parameter must be an Integer in Block IO read rate Bps device" unless value['Rate'].is_a?(Integer)
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:blkio_device_write_bps, :array_matching => :all) do
    desc 'Limit write rate (bytes per second) to a device in the form of: [{"Path" => "device_path", "Rate" => rate}]'

    validate do |value|
      raise ArgumentError, "Missing 'Path' in Block IO write rate Bps device" unless value.has_key?('Path')
      raise ArgumentError, "Missing 'Rate' in Block IO write rate Bps device" unless value.has_key?('Rate')
      raise ArgumentError, "'Rate' parameter must be an Integer in Block IO write rate Bps device" unless value['Rate'].is_a?(Integer)
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:blkio_device_read_iops, :array_matching => :all) do
    desc 'Limit read rate (IO per second) from a device in the form of: [{"Path" => "device_path", "Rate" => rate}]'

    validate do |value|
      raise ArgumentError, "Missing 'Path' in Block IO read rate IOPS device" unless value.has_key?('Path')
      raise ArgumentError, "Missing 'Rate' in Block IO read rate IOPS device" unless value.has_key?('Rate')
      raise ArgumentError, "'Rate' parameter must be an Integer in Block IO read rate IOPS device" unless value['Rate'].is_a?(Integer)
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:blkio_device_write_iops, :array_matching => :all) do
    desc 'Limit write rate (IO per second) to a device in the form of [{"Path" => "device_path", "Rate" => rate}]'

    validate do |value|
      raise ArgumentError, "Missing 'Path' in Block IO write rate IOPS device" unless value.has_key?('Path')
      raise ArgumentError, "Missing 'Rate' in Block IO write rate IOPS device" unless value.has_key?('Rate')
      raise ArgumentError, "'Rate' parameter must be an Integer in Block IO write rate IOPS device" unless value['Rate'].is_a?(Integer)
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:memory_swappiness) do
    desc "Tune a container memory swappiness behavior. Accepts an integer between 0 and 100."

    validate do |value|
      raise ArgumentError, "Container memory swappiness '#{value}' is not an Integer" unless value.is_a?(Integer)
      raise ArgumentError, "Container memory swappiness '#{value}' must be betwen 0 and 100" unless (value >= 0 and value <= 100)
    end
  end

  newproperty(:oom_kill_disable, :boolean => true) do
    desc "Whether to disable OOM Killer for the container or not."
    newvalues(:true, :false)
  end

  newproperty(:oom_score_adj) do
    desc "Tune container OOM preferences (-1000 to 1000)"

    validate do |value|
      raise ArgumentError, "Container OOM score '#{value}' is not an Integer" unless value.is_a?(Integer)
      raise ArgumentError, "Container OOM score '#{value}' must be between -1000 and 1000" unless (value >= -1000 and value <= 1000)
    end
  end

  newproperty(:pid_mode) do
    desc "Set the PID (Process) Namespace mode for the container"
    newvalues('', 'host', /^container:(\w+)$/)
    defaultto('')
  end

  newproperty(:pids_limit) do
    desc "Tune a container pids limit. Set -1 for unlimited"

    validate do |value|
      raise ArgumentError, "Container PIDs limit '#{value}' is not an Integer" unless value.is_a?(Integer)
      raise ArgumentError, "Container PIDs limit '#{value}' must be >= -1" unless value >= -1
    end
  end

  newproperty(:port_bindings) do
    desc 'A map of exposed container ports and the host port they should map to in the form {"<port>/<protocol>" => [{"HostPort" => "<port>"}]}'

    validate do |value|
      raise ArgumentError, "Container port bindings '#{value}' is not a Hash" unless value.is_a?(Hash)

      value.each do |container_port, host_port|
        if container_port !~ /^\d+\/(tcp|udp)$/
          raise ArgumentError, "Container port binding '#{container_port}' must be in the form of <port>/<tcp|udp>"
        end

        raise ArgumentError, "Container port binding host port '#{host_port}' is not an Array" unless host_port.is_a?(Array)
        raise ArgumentError, "Container port binding host port '#{host_port}' must have at least one element" unless host_port.size > 0
        host_port.each do |p|
          raise ArgumentError, "Missing 'HostPort' parameter in container port binding '#{container_port}'" unless p.has_key?('HostPort')
          raise ArgumentError, "'HostPort' parameter must be a String in container port binding '#{container_port}'" unless p['HostPort'].is_a?(String)
        end
      end
    end

    def insync?(current)
      return false if current == :absent
      @should.first.each do |container_port, host_config|
        found = false
        current.each do |current_container_port, current_host_config|
          if container_port == current_container_port
            host_config.each.with_index do |h, i|
              return false if current_host_config[i]['HostPort'] != h['HostPort']
            end
            found = true
            break
          end
        end
        return false unless found
      end

      current.each do |current_container_port, current_host_config|
        found = false
        @should.first.each do |container_port, host_config|
          if current_container_port == container_port
            found = true
            break
          end
          return false unless found
        end
      end

      true
    end

    def should
      return nil unless @should
      @should.first
    end
  end

  newproperty(:publish_all_ports, :boolean => true) do
    desc "Allocates a random host port for all of a container exposed ports"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:privileged, :boolean => true) do
    desc "Gives the container full access to the host"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:readonly_rootfs, :boolean => true) do
    desc "Mount the container root filesystem as read only"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:dns, :array_matching => :all) do
    desc "A list of DNS servers for the container to use"

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:dns_options, :array_matching => :all) do
    desc "A list of DNS options"

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:dns_search, :array_matching => :all) do
    desc "A list of DNS search domains"

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:extra_hosts, :array_matching => :all) do
    desc 'A list of hostnames/IP mappings to add to the container /etc/hosts file. Specified in the form ["hostname:IP"].'

    validate do |value|
      if value !~ /^.+:(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
        raise ArgumentError, "Container port binding '#{value}' must be in the form of <hostname>:<ip>"
      end
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end

  end

  newproperty(:volumes_from, :array_matching => :all) do
    desc "A list of volumes to inherit from another container. Specified in the form <container name>:<ro|rw>"

    validate do |value|
      if value !~ /^.+:r[wo]$/
        raise ArgumentError, "Container volume from '#{value}' must be in the form of <container name>:<ro|rw>"
      end
    end

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:cap_add, :array_matching => :all) do
    desc "A list of kernel capabilities to add to the container"

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:cap_drop, :array_matching => :all) do
    desc "A list of kernel capabilities to drop from the container"

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:group_add, :array_matching => :all) do
    desc 'A list of additional groups that the container process will run as'

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:restart_policy) do
    desc 'The behavior to apply when the container exits'
    newvalues(/^on-failure(:\d+)?$/, 'always', 'unless-stopped')
  end

  newproperty(:userns_mode) do
    desc 'Sets the usernamespace mode for the container when usernamespace remapping option is enabled'
  end

  newproperty(:network_mode) do
    desc 'Sets the networking mode for the container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network name to which this container should connect to.'
  end

  newproperty(:devices, :array_matching => :all) do
    desc 'A list of devices to add to the container specified in the form {"PathOnHost" => "/dev/deviceName", "PathInContainer" => "/dev/deviceName", "CgroupPermissions" => "mrw"}'

    validate do |value|
      raise ArgumentError, "Container device '#{value}' is not a Hash" unless value.is_a?(Hash)
      raise ArgumentError, "Missing 'PathOnHost' parameter in container device" unless value.has_key?('PathOnHost')
      raise ArgumentError, "Missing 'PathInContainer' parameter in container device" unless value.has_key?('PathInContainer')
      raise ArgumentError, "Missing 'CgroupPermissions' parameter in container device" unless value.has_key?('CgroupPermissions')
    end

    def insync?(current)
      return false if current == :absent
      return current == @should     
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newproperty(:ulimits, :array_matching => :all) do
    desc 'A list of ulimits to set in the container, specified as {"Name" => <name>, "Soft" => <soft limit>, "Hard" => <hard limit>}'

    validate do |value|
      raise ArgumentError, "Container ulimit '#{value}' is not a Hash" unless value.is_a?(Hash)
      raise ArgumentError, "Missing 'Name' parameter in container ulimit" unless value.has_key?('Name')
      raise ArgumentError, "Missing 'Soft' parameter in container ulimit" unless value.has_key?('Soft')
      raise ArgumentError, "Missing 'Hard' parameter in container ulimit" unless value.has_key?('Hard')
    end

    def insync?(current)
      return false if current == :absent
      return current == @should     
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newparam(:sysctls) do
    desc 'A list of kernel parameters (sysctls) to set in the container, specified as {<name> => <Value> }, for example: {"net.ipv4.ip_forward" => ""}'

    validate do |value|
      raise ArgumentError, "Container sysctls '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newproperty(:security_opt, :array_matching => :all) do
    desc 'A list of string values to customize labels for MLS systems, such as SELinux'
    newvalues(/^label:((user|role|type|level):.+|disable)$/, /^apparmor:.+$/, 'no-new-privileges', /^seccomp:.+$/)
    defaultto(["label:disable"])

    def insync?(current)
      return false if current == :absent
      return current == @should
    end

    def should
      return nil unless @should
      @should
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        nil
      end
    end
  end

  newparam(:storage_opt) do
    desc 'Storage driver options per container. Options can be passed in the form {"size" => "120G"}'

    validate do |value|
      raise ArgumentError, "Container security options '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newproperty(:log_driver) do
    desc 'Log driver for the container'
    newvalues('json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'awslogs', 'splunk', 'etwlogs', 'none')
  end

  newproperty(:log_opts) do
    desc 'Log driver options for the container'

    validate do |value|
      raise ArgumentError, "Log driver options is not a Hash" unless value.is_a?(Hash)

      value.each do |k, v|
        raise ArgumentError, "Log driver option '#{k}' must be a String" unless v.is_a?(String)
      end
    end
  end

  newproperty(:cgroup_parent) do
    desc 'Path to cgroups under which the container cgroup is created. If the path is not absolute, the path is considered to be relative to the cgroups path of the init process. Cgroups are created if they do not already exist.'
    defaultto('')
  end

  newproperty(:volume_driver) do
    desc 'Driver that this container users to mount volumes'
    defaultto('')
  end

  newproperty(:shm_size) do
    desc 'Size of /dev/shm in bytes. The size must be greater than 0.'

    validate do |value|
      raise ArgumentError, "Container shared memory size '#{value}' is not an Integer" unless value.is_a?(Integer)
    end
  end

  def refresh
    if (@parameters[:ensure] == :running || newattr(:ensure)).retrieve == :running
      provider.restart
    else
      debug "Skipping restart; container is not running"
    end
  end

  autorequire(:service) do
    ["docker"]
  end

  autorequire(:docker_image) do
    [self[:image]]
  end
end
