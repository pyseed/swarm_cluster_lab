# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.vagrantup.com/docs/vagrantfile/machine_settings.html

# managers and workers count
MANAGERS = 1
WORKERS = 2

# location of stack to bind in sync folder /stack (default is ./stack example)
STACK = ENV["SCL_STACK"] || "stack"

PROVIDER = "virtualbox"
BOX_NAME = "hashicorp/bionic64"
# if false, explicit 'vagrant box update' is required
BOX_CHECK_UPDATE = false
BOX_HALT_TIMEOUT = 30

# activate/desactivate OS update at provisioning (time consuming)
OS_UPDATE = true

# provision scripts path
PROVISION_DIR = "./provision/"

STORAGE_RAM = ENV["SCL_STORAGE_RAM"] || 512
STORAGE_HOSTNAME = 'storage'
# ip should match provisionNfsServerIp of provision.env
STORAGE_IP = "10.0.10.10"
STORAGE_UP_MESSAGE = ""

DATA_RAM = ENV["SCL_DATA_RAM"] || 1024
DATA_HOSTNAME = 'data'
# ip should match provisionDataIp of provision.env
DATA_IP = "10.0.10.11"
DATA_UP_MESSAGE = ""
# activate postgres in data storage
DATA_POSTGRES = false

MANAGER_RAM = ENV["SCL_MANAGER_RAM"] || 1024
MANAGER_HOSTNAME_BASE = 'manager'
# manager leader (1st) ip should match managerIp of provision.env
# ip(s) should be in range of provisionNfsClientRange of provision.env
MANAGER_IP_BASE = "10.0.10.2"
MANAGER_UP_MESSAGE = "/mnt/storage to access storage. registry host to access docker registry."

WORKER_RAM = ENV["SCL_WORKER_RAM"] || 2048
WORKER_HOSTNAME_BASE = 'worker'
# ip(s) should be in range of provisionNfsClientRange of provision.env
WORKER_IP_BASE = "10.0.10.3"
WORKER_UP_MESSAGE = "/mnt/storage to access storage. registry host to access docker registry."

ENV["LC_ALL"] = "en_US.UTF-8"

def provision_file(node, src, target)
  node.vm.provision "file", source: src, destination: target
end

def provision_shell(node, file, root=true)
  node.vm.provision "shell", path: PROVISION_DIR + file, privileged: root
end

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
    provision_shell(node, "silent_update.sh")
  end
  provision_file(node, "./provision.env", "/tmp/provision.env")
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
    provision_file(manager, "~/.ssh/id_rsa", ".ssh/id_rsa")
    provision_file(manager, "~/.ssh/id_rsa.pub", ".ssh/id_rsa.pub")
    provision_file(manager, "~/.gitconfig", ".gitconfig")

    # provisioning
    provision_shell(manager, "nfs_client.sh")
    provision_shell(manager, "registry_client.sh")
    provision_shell(manager, "data_client.sh")
    provision_shell(manager, "docker.sh")
    provision_shell(manager, "manager_packages.sh")
    if index == 1
      provision_shell(manager, "swarm_init.sh")
    else
      provision_shell(manager, "manager_join.sh")
    end
  end
end

def set_worker(config, index)
  hostname = WORKER_HOSTNAME_BASE + index.to_s
  ip = WORKER_IP_BASE + index.to_s

  config.vm.define hostname do |worker|
    set_vm(worker, WORKER_RAM, hostname, ip, WORKER_UP_MESSAGE)

  # provisioning
    provision_shell(worker, "nfs_client.sh")
    provision_shell(worker, "registry_client.sh")
    provision_shell(worker, "data_client.sh")
    provision_shell(worker, "docker.sh")
    provision_shell(worker, "worker_packages.sh")
    provision_shell(worker, "worker_join.sh")
  end
end


Vagrant.configure("2") do |config|
  # storage node
  # WARNING: destroying it = loss of data (persistent volumes)
  config.vm.define STORAGE_HOSTNAME do |storage|
    set_vm(storage, STORAGE_RAM, STORAGE_HOSTNAME, STORAGE_IP, STORAGE_UP_MESSAGE)
    provision_shell(storage, "nfs_server.sh")
  end

  # data node
  # WARNING: destroying it = loss of data (databases, ...)
  config.vm.define DATA_HOSTNAME do |data|
    set_vm(data, DATA_RAM, DATA_HOSTNAME, DATA_IP, DATA_UP_MESSAGE)
    provision_shell(data, "docker.sh")
    provision_shell(data, "registry_server.sh")
    if DATA_POSTGRES
      provision_shell(data, "data_postgres.sh")
    end
  end

  # managers
  for i in 1..MANAGERS do
    set_manager(config, i)
  end

  # workers
  for i in 1..WORKERS do
    set_worker(config, i)
  end
end
