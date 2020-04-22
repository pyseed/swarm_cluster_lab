#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q git tar tree vim

# swarm init
docker swarm init --advertise-addr ${managerIp}
