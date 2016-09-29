#
# docker_api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.type(:docker_volume).provide(:docker_api) do
  desc "Docker volume provider"

  confine :feature => :docker_api

  require 'docker'

  # Use the docker unix socket for communicating with the daemon
  Docker.url = "unix:///var/run/docker.sock"

  def self.instances
    instances = []

    Docker::Volume.all.each do |volume|
      instances << new(
        :id => volume.id,
        :name => volume.info['Name'],
        :ensure => :present
      )
    end

    instances
  end

  def self.prefetch(resources)
    volumes = instances
    resources.keys.each do |name|
      if provider = volumes.find { |volume| volume.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    config = {}
    config['Driver'] = resource[:driver] if resource[:driver]
    config['DriverOpts'] = resource[:driver_opts] if resource[:driver_opts]
    config['Labels'] = resource[:labels] if resource[:labels]

    # FIXME: depends on https://github.com/swipely/docker-api/pull/451
    #Docker::Volume.create(resource[:name], config)
    Docker::Volume.create(resource[:name])
    @property_hash[:ensure] = :present
  end

  def destroy
    volume = Docker::Volume.get(@property_hash[:id])
    volume.remove
    @property_hash.clear
  end
end
