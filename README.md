# Puppet types and providers for Docker

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the docker module](#setup)
4. [Reference - Types reference and additional functionalities](#reference)
5. [Hiera integration](#hiera)
6. [Contact](#contact)

<a name="overview"/>

## Overview

This module implements native types and providers to manage some aspects of Docker. The providers are *fully idempotent* and they only rely
on the docker metadata.

For docker containers, when changing parameters that cannot be updated without restarting the container, there's an optional boolean flag called
[*remove_on_change*](#remove_on_change) which allows to you either remove the container or rename it to a random UUID.

Docker 1.12.1 or above is highly recommended.

<a name="module-description"/>

## Module Description

The docker module allows to automate the configuration and runtime of containers as well as the deployment of images, networks and volumes.

<a name="setup"/>

## Setup

The module requires the [docker-api](https://rubygems.org/gems/docker-api) rubygem. It also requires Puppet >= 4.0.0.

Install the rubygem as follows:

```
/opt/puppetlabs/puppet/bin/gem install docker-api
```

The include the main class as follows:

```
include docker
```

<a name="reference"/>

## Reference

### Classes

#### docker
`docker`

```
include docker
```

##### `images` (optional)
Docker images in the form of {'image_name' => { .. }}

##### `containers` (optional)
Docker containers in the form of {'container_name' => { .. }}

##### `networks` (optional)
Docker networks in the form of {'network_name' => { .. }}

##### `volumes` (optional)
Docker volumes in the form of {'volume_name' => { .. }}

##### `opts` (optional)
Docker daemon options in the form of {'option' => 'value'}.

Defaults to:
```
docker::opts:
  'host':
    - 'unix:///var/run/docker.sock'
  'log-driver': journald
```

##### `config_dir` (optional)
Path to the docker configuration directory (default: '/etc/docker')

##### `config_file` (optional)
Path to the docker daemon configuration file (default: '$config_dir/daemon.json')

##### `config_file_manage` (optional)
Whether we should manage the docker configuration file or not (default: true)

##### `package_name` (optional)
Installation packge for Docker (default: 'docker')

##### `service_name` (optional)
Docker service name (default: 'docker')

##### `service_manage` (optional)
Whether we should manage the service runtime or not (default: true)

##### `service_ensure` (optional)
Whether the resource is running or not. Valid values are 'running', 'stopped'. (default: 'running')

##### `service_enable` (optional)
Whether the service is onboot enabled or not. Defaults to true.

### Types

#### docker_image
`docker_image` manages Docker images

```
docker_image {"centos:latest": }
```

##### `name` (required)
Docker image

##### `image_name` (optional)
Docker image name, defaults to name

##### `image_tag` (optional)
Docker image tag, defaults to name

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `force`
Force image removal. Must be a Boolean, default is false.

#### docker_container
`docker_container` manages Docker containers

```
docker_container {"helloworld":
  image => "centos:latest",
  cmd => ["/usr/bin/sleep", "100"],
  ensure => "running"
```

Note that only the following parameters can be changed *without* re-creating the container:

  * blkio_weight
  * cpu_shares
  * cpu_period
  * cpu_quota
  * cpuset_cpus
  * cpuset_mems
  * memory
  * memory_swap
  * memory_reservation
  * kernel_memory
  * restart_policy


##### `name` (required)
Docker container name

<a name="remove_on_change"/>

##### `remove_on_change` (optional)
When set to true, log, remove and re-create the container when changing non-runtime parameters. When false, the container will be
renamed to a random UUID before re-creating it. Valid values are true or false. Defaults to false.

##### `image` (required)
A string specifying the image name to use for the container.

##### `ensure` (required)
Whether the resource is present or not. Valid values are 'present', 'running', 'stopped', 'absent'. Defaults to 'present'.

##### `hostname` (optional)
A string value containing the hostname to use for the container. This must be a valid RFC 1123 hostname.

##### `domain_name` (optional)
A string value containing the domain name to use for the container

##### `user` (optional)
A string value specifying the user inside the container

##### `attach_stdin` (optional)
Boolean value, attaches to stdin.

##### `attach_stdout` (optional)
Boolean value, attaches to stdout.

##### `attach_stderr` (optional)
Boolean value, attaches to stderr.

##### `tty` (optional)
Boolean value, Attach standard streams to a tty, including stdin if it is not closed.

##### `open_stdin` (optional)
Boolean value, opens stdin.

##### `stdin_once` (optional)
Boolean value, close stdin after the 1 attached client disconnects.

##### `env` (optional)
A list of environment variables in the form of ["VAR=value", "VAR2=value2" ..]

##### `cmd` (optional)
Command to run specified as a string or an array of strings

##### `entrypoint` (optional)
Set the entry point for the container as a string or an array of strings.

##### `labels` (optional)
Adds a map of labels to a container. To specify a map: {"key":"value"[,"key2":"value2"]}.

##### `volumes` (optional)
An object mapping mount point paths (strings) inside the container to empty objects.

##### `workdir` (optional)
A string specifying the working directory for commands to run in.

##### `network_disabled` (optional)
Boolean value, when true disables networking for the container

##### `stop_signal` (optional)
Signal to stop a container as a string or unsigned integer. SIGTERM by default.

##### `binds` (optional)
A list of volume bindings for this container. Each volume binding is a string in one of these forms:

  * host_path:container_path to bind-mount a host path into the container
  * host_path:container_path:ro to make the bind-mount read-only inside the container.
  * volume_name:container_path to bind-mount a volume managed by a volume plugin into the container.
  * volume_name:container_path:ro to make the bind mount read-only inside the container.

##### `links` (optional)
A list of links for the container. Each link entry should be in the form of container_name:alias.

##### `memory` (optional)
Memory limit in bytes.

##### `memory_swap` (optional)
Total memory limit (memory + swap); set -1 to enable unlimited swap. You must use this with memory and make the swap value larger than memory.

##### `memory_reservation` (optional)
Memory soft limit in bytes.

##### `kernel_memory` (optional)
Kernel memory limit in bytes.

##### `cpu_percent` (optional)
An integer value containing the usable percentage of the available CPUs. (Windows daemon only)

##### `cpu_shares` (optional)
An integer value containing the container’s CPU Shares (ie. the relative weight vs other containers).

##### `cpu_period` (optional)
The length of a CPU period in microseconds.

##### `cpu_quota` (optional)
Microseconds of CPU time that the container can get in a CPU period.

##### `cpuset_cpus` (optional)
String value containing the cgroups CpusetCpus to use.

##### `cpuset_mems` (optional)
Memory nodes (MEMs) in which to allow execution (0-3, 0,1). Only effective on NUMA systems.

##### `maximum_iops` (optional)
Maximum IO absolute rate in terms of IOps.

##### `maximum_iobps` (optional)
Maximum IO absolute rate in terms of bytes per second.

##### `blkio_weight` (optional)
Block IO weight (relative weight) accepts a weight value between 10 and 1000.

##### `blkio_weight_device` (optional)
Block IO weight (relative device weight) in the form of: [{"Path": "device_path", "Weight": weight}]

##### `blkio_device_read_bps` (optional)
Limit read rate (bytes per second) from a device in the form of: [{"Path": "device_path", "Rate": rate}], for example: [{"Path": "/dev/sda", "Rate": "1024"}]"

##### `blkio_device_write_bps` (optional)
Limit write rate (bytes per second) to a device in the form of: [{"Path": "device_path", "Rate": rate}], [{"Path": "/dev/sda", "Rate": "1024"}]"

##### `memory_swappiness` (optional)
Tune a container’s memory swappiness behavior. Accepts an integer between 0 and 100.

##### `oom_kill_disable` (optional)
Boolean value, whether to disable OOM Killer for the container or not.

##### `oom_score_adj` (optional)
An integer value containing the score given to the container in order to tune OOM killer preferences.

##### `pid_mode` (optional)
Set the PID (Process) Namespace mode for the container; "container:<name|id>": joins another container’s PID namespace, "host": use the host’s PID namespace inside the container.

##### `pids_limit` (optional)
Tune a container’s pids limit. Set -1 for unlimited.

##### `port_bindings` (optional)
A map of exposed container ports and the host port they should map to, in the form of {"<port>/<protocol>" => [{ "HostPort" => "<port>"}]}. Take note that port is specified as a string and not an integer value.

##### `publish_all_ports` (optional)
Allocates a random host port for all of a container’s exposed ports. Specified as a boolean value.

##### `privileged` (optional)
Gives the container full access to the host. Specified as a boolean value.

##### `readonly_rootfs` (optional)
Mount the container’s root filesystem as read only. Specified as a boolean value.

##### `dns` (optional)
A list of DNS servers for the container to use.

##### `dns_options` (optional)
A list of DNS options

##### `dns_search` (optional)
A list of DNS search domains

##### `extra_hosts` (optional)
A list of hostnames/IP mappings to add to the container’s /etc/hosts file. Specified in the form ["hostname:IP"].

##### `volumes_from` (optional)
A list of volumes to inherit from another container. Specified in the form <container name>[:<ro|rw>].

##### `cap_add` (optional)
A list of kernel capabilities to add to the container.

##### `cap_drop` (optional)
A list of kernel capabilities to drop from the container.

##### `group_add` (optional)
A list of additional groups that the container process will run as

##### `restart_policy` (optional)
The behavior to apply when the container exits. The value is one of: on-failure:<maximum_number_of_retries>, always, unless-stopped.

##### `userns_mode` (optional)
Sets the usernamespace mode for the container when usernamespace remapping option is enabled. supported values are: host.

##### `network_mode` (optional)
Sets the networking mode for the container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network’s name to which this container should connect to.

##### `devices` (optional)
A list of devices to add to the container specified in the form {"PathOnHost" => "/dev/deviceName", "PathInContainer" => "/dev/deviceName", "CgroupPermissions": "mrw"}.

##### `ulimits` (optional)
A list of ulimits to set in the container, specified as {"Name" => <name>, "Soft" => <soft limit>, "Hard" => <hard limit>}, for example: {"Name" => "nofile", "Soft" => 1024, "Hard" => 2048}.

##### `sysctls` (optional)
A list of kernel parameters (sysctls) to set in the container, specified as {<name> => <Value>}, for example: {"net.ipv4.ip_forward" => "1" }.

##### `security_opt` (optional)
A list of string values to customize labels for MLS systems, such as SELinux.

##### `storage_opt` (optional)
Storage driver options per container. Options can be passed in the form {"size" => "120G"}.

##### `log_driver` (optional)
Logging driver. Available types are: json-file, syslog, journald, gelf, fluentd, awslogs, splunk, etwlogs, none, json-file

##### `log_opts` (optional)
Logging driver options, specified as {"key1" => "value1"}

##### `cgroup_parent` (optional)
Path to cgroups under which the container’s cgroup is created. If the path is not absolute, the path is considered to be relative to the cgroups path of the init process. Cgroups are created if they do not already exist.

##### `volume_driver` (optional)
Driver that this container users to mount volumes.

##### `shm_size` (optional)
Size of /dev/shm in bytes. The size must be greater than 0. If omitted the system uses 64MB.

#### docker_volume
`docker_volume` manages Docker volumes

```
docker_volume {"data":
  ensure => "present"
}
```

##### `name` (required)
Docker volume name

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `driver` (optional)
Name of the volume driver to use

##### `driver_opts` (optional)
A mapping og driver options and values.

##### `labels` (optional)
Labels to set on the volume, specified as a map: {"key" => "value","key2" => "value2"}

#### docker_network
`docker_network` manages Docker networks

```
docker_network {"fast":
  ensure => "present"
}
```

##### `name` (required)
Docker network name

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `check_duplicate` (optional)
Requests daemon to check for networks with same name

##### `driver` (optional)
Name of the network driver plugin to use

##### `internal` (optional)
Restrict external access to the network

##### `ipam` (optional)
Optional custom IP scheme for the network

##### `enable_ipv6` (optional)
Enable IPv6 on the network

##### `options` (optional)
Network specific options to be used by the drivers

##### `labels` (optional)
Labels to set on the network, specified as a map: {"key" => "value","key2" => "value2"}

<a name="hiera"/>

## Hiera integration

You can optionally define your images, containers, volumes and networks in Hiera.

```
---
docker::images:
  "centos:latest":
    ensure: "present"
docker::containers:
  "mycontainer":
    image: "centos:latest"
    cmd: ["/usr/bin/sleep", "60"]
    ensure: "running"
docker::networks:
  "prod":
    ensure: "present"
docker::volumes:
  "data":
    ensure: "present"
```

<a name="contact"/>

## Contact

Matteo Cerutti - matteo.cerutti@hotmail.co.uk
