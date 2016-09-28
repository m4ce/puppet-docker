#
# docker_api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.type(:docker_network).provide(:docker_api) do
  desc "Docker network provider"

  confine :feature => :docker_api

  require 'docker'

  # Use the docker unix socket for communicating with the daemon
  Docker.url = "unix:///var/run/docker.sock"

  def self.instances
    instances = []

    Docker::Network.all.each do |network|
      instances << new(
        :id => network.id,
        :name => network.info['Name'],
        :ensure => :present
      )
    end

    instances
  end

  def self.prefetch(resources)
    networks = instances
    resources.keys.each do |name|
      if provider = networks.find { |network| network.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    config = {}
    unless resource[:check_duplicate].nil?
      config['CheckDuplicate'] = resource[:check_duplicate] == :true ? true : false
    end

    config['Driver'] = resource[:driver] if resource[:driver]

    unless resource[:internal].nil?
      config['Internal'] = resource[:internal] == :true ? true : false
    end

    config['IPAM'] = resource[:ipam] if resource[:ipam]

    unless resource[:enable_ipv6].nil?
      config['EnableIPv6'] = resource[:enable_ipv6] == :true ? true : false
    end

    config['Options'] = resource[:options] if resource[:options]
    config['Labels'] = resource[:labels] if resource[:labels]

    Docker::Network.create(resource[:name], config)
    @property_hash[:ensure] = :present
  end

  def destroy
    network = Docker::Network.get(@property_hash[:id])
    network.remove
    @property_hash.clear
  end
end
