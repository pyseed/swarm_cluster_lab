# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.vagrantup.com/docs/vagrantfile/machine_settings.html

BOX_NAME = "hashicorp/bionic64"
# if false, explicit 'vagrant box update' is required
BOX_CHECK_UPDATE = false

# activate/desactivate OS update at provisioning (time consuming)
#OS_UPDATE = "./provision/silent_update.sh"
OS_UPDATE = "./provision/true.sh"

STORAGE_HOSTNAME = 'storage'
STORAGE_RAM = 512
STORAGE_IP = "10.0.10.10"
STORAGE_UP_MESSAGE = STORAGE_IP + " hostname '" + STORAGE_HOSTNAME + "' ready"

MANAGER_HOSTNAME = 'manager'
MANAGER_RAM = 1024
MANAGER_IP = "10.0.10.20"
MANAGER_UP_MESSAGE = MANAGER_IP + " hostname '" + MANAGER_HOSTNAME + "' ready. /mnt/storage to access storage."

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|

  #
  # storage server
  #
  config.vm.define STORAGE_HOSTNAME do |storage|
    storage.vm.box = BOX_NAME
    storage.vm.box_check_update = BOX_CHECK_UPDATE
    storage.vm.graceful_halt_timeout = 30
    storage.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = STORAGE_RAM
    end
    storage.vm.hostname = STORAGE_HOSTNAME
    storage.vm.network "private_network", ip: STORAGE_IP

    storage.vm.provision "shell", path: OS_UPDATE
    storage.vm.provision "file", source: "./provision.env", destination: "/tmp/provision.env"
    storage.vm.provision "shell", path: "./provision/nfs_server.sh"

    storage.vm.post_up_message = STORAGE_UP_MESSAGE
  end

  #
  # manager
  #
  config.vm.define MANAGER_HOSTNAME do |manager|
    manager.vm.box = BOX_NAME
    manager.vm.box_check_update = BOX_CHECK_UPDATE
    manager.vm.graceful_halt_timeout = 30
    manager.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = MANAGER_RAM
    end
    manager.vm.hostname = MANAGER_HOSTNAME
    manager.vm.network "private_network", ip: MANAGER_IP

    manager.vm.provision "shell", path: OS_UPDATE
    manager.vm.provision "file", source: "./provision.env", destination: "/tmp/provision.env"
    manager.vm.provision "shell", path: "./provision/nfs_client.sh"

    manager.vm.post_up_message = MANAGER_UP_MESSAGE
  end
end
