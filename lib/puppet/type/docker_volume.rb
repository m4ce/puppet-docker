#
# docker_volume.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.newtype(:docker_volume) do
  @doc = 'Docker volume'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc "The new volume’s name"
    isnamevar
  end

  newparam(:driver) do
    desc "Name of the volume driver to use"
  end

  newparam(:driver_opts) do
    desc "A mapping of driver options and values. These options are passed directly to the driver and are driver specific."
  end

  newparam(:labels) do
    desc 'Labels to set on the volume, specified as a map: {"key":"value","key2":"value2"}'
  end

  autorequire(:service) do
    ["docker"]
  end
end
