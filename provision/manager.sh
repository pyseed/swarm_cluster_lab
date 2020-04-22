#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q git tar tree vim

# join swarm as manager
TOKEN=$(docker -H tcp://${managerIp}:2375 swarm join-token -q manager)
docker swarm join --token $TOKEN ${managerIp}:2377
