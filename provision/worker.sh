#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q vim

# join swarm as worker
TOKEN=$(docker -H tcp://${managerIp}:2375 swarm join-token -q worker)
docker swarm join --token $TOKEN ${managerIp}:2377
