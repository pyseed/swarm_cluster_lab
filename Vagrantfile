# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.vagrantup.com/docs/vagrantfile/machine_settings.html

#
# a cluster composed of following nodes:
# - storage: nfs server (shared between nodes persistent volumes) and docker registry for 'local swarm builds'
# - 1 manager 1 manager (candidate to deploy traefik (swarm api access))
# - 2 workers
#

# location of stack to bind in sync folder /stack (default is ./stack example)
STACK = ENV["SCL_STACK"] || "stack"

PROVIDER = "virtualbox"
BOX_NAME = "hashicorp/bionic64"
# if false, explicit 'vagrant box update' is required
BOX_CHECK_UPDATE = false
BOX_HALT_TIMEOUT = 30

# activate/desactivate OS update at provisioning (time consuming)
OS_UPDATE = true

STORAGE_RAM = ENV["SCL_STORAGE_RAM"] || 512
STORAGE_HOSTNAME = 'storage'
# storage ip should match provisionNfsServerIp of provision.env
STORAGE_IP = "10.0.10.10"
STORAGE_UP_MESSAGE = ""

MANAGER_RAM = ENV["SCL_MANAGER_RAM"] || 1536
MANAGER_HOSTNAME_BASE = 'manager'
# 1st manager (Leader) should match managerIp of provision.env
# manager ip(s) should be in range of provisionNfsClientRange of provision.env
MANAGER_IP_BASE = "10.0.10.2"
MANAGER_UP_MESSAGE = "/mnt/storage to access storage. registry host to access docker registry."

WORKER_RAM = ENV["SCL_WORKER_RAM"] || 2048
WORKER_HOSTNAME_BASE = 'worker'
# workers ip(s) should be in range of provisionNfsClientRange of provision.env
WORKER_IP_BASE = "10.0.10.3"
WORKER_UP_MESSAGE = "/mnt/storage to access storage. registry host to access docker registry."

ENV["LC_ALL"] = "en_US.UTF-8"


def set_vm(node, ram, hostname, ip, up_message)
  node.vm.box = BOX_NAME
  node.vm.box_check_update = BOX_CHECK_UPDATE
  node.vm.graceful_halt_timeout = BOX_HALT_TIMEOUT
  node.vm.provider PROVIDER do |vb|
    vb.gui = false
    vb.memory = ram
  end
  node.vm.hostname = hostname
  node.vm.post_up_message = ip + " hostname '" + hostname + "' ready. " + up_message

  unless ip.empty?
    node.vm.network "private_network", ip: ip
  end

  # disable the default project tree sync folder
  node.vm.synced_folder ".", "/vagrant", disabled: true

  if OS_UPDATE
    node.vm.provision "shell", path: "./provision/silent_update.sh"
  end
end

def set_manager(config, index)
  hostname = MANAGER_HOSTNAME_BASE + index.to_s
  ip = MANAGER_IP_BASE + index.to_s

  config.vm.define hostname do |manager|
    set_vm(manager, MANAGER_RAM, hostname, ip, MANAGER_UP_MESSAGE)

    if index == 1
      # forward traefik port: from host access url such like portainer.localhost:9080
      manager.vm.network :forwarded_port, guest: 80, host: 9080
      # forward traefik ui: localhost:9088 is an alias of MANAGER_IP:8080
      manager.vm.network :forwarded_port, guest: 8080, host: 9088
    end

    manager.vm.synced_folder STACK, "/stack"

    # manager uses git config (then ssh identity) for user stacks
    manager.vm.provision "file", source: "~/.ssh/id_rsa", destination: ".ssh/id_rsa"
    manager.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: ".ssh/id_rsa.pub"
    manager.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

    manager.vm.provision "file", source: "./provision.env", destination: "/tmp/provision.env"
    manager.vm.provision "shell", path: "./provision/nfs_client.sh"
    manager.vm.provision "shell", path: "./provision/registry_client.sh"
    manager.vm.provision "shell", path: "./provision/docker.sh"
    manager.vm.provision "shell", path: "./provision/manager_packages.sh"
    if index == 1
      manager.vm.provision "shell", path: "./provision/swarm_init.sh"
    else
      manager.vm.provision "shell", path: "./provision/manager_join.sh"
    end
  end
end

def set_worker(config, index)
  hostname = WORKER_HOSTNAME_BASE + index.to_s
  ip = WORKER_IP_BASE + index.to_s

  config.vm.define hostname do |worker|
    set_vm(worker, WORKER_RAM, hostname, ip, WORKER_UP_MESSAGE)

    worker.vm.provision "file", source: "./provision.env", destination: "/tmp/provision.env"
    worker.vm.provision "shell", path: "./provision/nfs_client.sh"
    worker.vm.provision "shell", path: "./provision/registry_client.sh"
    worker.vm.provision "shell", path: "./provision/docker.sh"
    worker.vm.provision "shell", path: "./provision/worker_packages.sh"
    worker.vm.provision "shell", path: "./provision/worker_join.sh"
  end
end


Vagrant.configure("2") do |config|
  # storage node
  # WARNING: destroying it = loss of data (persistent volumes)
  config.vm.define STORAGE_HOSTNAME do |storage|
    set_vm(storage, STORAGE_RAM, STORAGE_HOSTNAME, STORAGE_IP, STORAGE_UP_MESSAGE)

    storage.vm.provision "file", source: "./provision.env", destination: "/tmp/provision.env"
    storage.vm.provision "shell", path: "./provision/nfs_server.sh"
    # docker is required for registry_server.sh script
    storage.vm.provision "shell", path: "./provision/docker.sh"
    storage.vm.provision "shell", path: "./provision/registry_server.sh"
  end

  # manager 1 node
  set_manager(config, 1)

  # manager 2 node
  # set_manager(config, 2)

  # worker 1 node
  set_worker(config, 1)

  # worker 2 node
  set_worker(config, 2)
end
