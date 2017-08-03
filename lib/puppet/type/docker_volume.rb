Puppet::Type.newtype(:docker_volume) do
  @doc = 'Docker volume'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc "The new volume’s name"
  end

  newparam(:driver) do
    desc "Name of the volume driver to use"
  end

  newparam(:driver_opts) do
    desc "A mapping of driver options and values. These options are passed directly to the driver and are driver specific."

    validate do |value|
      raise ArgumentError, "Docker volume driver options '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  newparam(:labels) do
    desc 'Labels to set on the volume, specified as a map: {"key" => "value","key2" => "value2"}'

    validate do |value|
      raise ArgumentError, "Docker volume labels '#{value}' is not a Hash" unless value.is_a?(Hash)
    end
  end

  autorequire(:service) do
    ["docker"]
  end
end
