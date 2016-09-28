#
# docker_api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'puppet/util/feature'

Puppet.features.add(:docker_api, :libs => ["docker"])
