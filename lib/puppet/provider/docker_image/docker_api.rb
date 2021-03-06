require 'docker' if Puppet.features.docker_api?

Puppet::Type.type(:docker_image).provide(:docker_api) do
  desc "Docker image provider"

  confine :feature => :docker_api

  def initialize(value = {})
    super(value)
    @property_flush = {}

    # Use the docker unix socket for communicating with the daemon
    Docker.url = "unix:///var/run/docker.sock"
  end

  def self.instances
    instances = []

    Docker::Image.all.each do |image|
      if image.info['RepoTags']
        image.info['RepoTags'].each do |repo_tag|
          instances << new(
            :id => image.id,
            :name => repo_tag,
            :image_name => repo_tag.split(':')[0],
            :image_tag => repo_tag.split(':')[1],
            :ensure => :present
          )
        end
      end
    end

    instances
  end

  def self.prefetch(resources)
    images = instances
    resources.each do |name, resource|
      if provider = images.find { |image| image.image_name == resource[:image_name] and image.image_tag == resource[:image_tag] }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Docker::Image.create('fromImage' => "#{resource[:image_name]}:#{resource[:image_tag]}")
    @property_hash[:ensure] = :present
  end

  def destroy
    image = Docker::Image.get(@property_hash['id'])
    image.remove(:force => resource[:force])
    @property_hash.clear
  end

  def image_name
    @property_hash[:image_name]
  end

  def image_tag
    @property_hash[:image_tag]
  end
end
