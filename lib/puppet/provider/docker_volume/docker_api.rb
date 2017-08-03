require 'docker' if Puppet.features.docker_api?

Puppet::Type.type(:docker_volume).provide(:docker_api) do
  desc "Docker volume provider"

  confine :feature => :docker_api

  def initialize(value = {})
    super(value)
    @property_flush = {}

    # Use the docker unix socket for communicating with the daemon
    Docker.url = "unix:///var/run/docker.sock"
  end

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

    Docker::Volume.create(resource[:name], config)
    @property_hash[:ensure] = :present
  end

  def destroy
    volume = Docker::Volume.get(@property_hash[:id])
    volume.remove
    @property_hash.clear
  end
end
