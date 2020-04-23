#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

TOKEN=$(docker -H tcp://${managerIp}:2375 swarm join-token -q manager)
docker swarm join --token $TOKEN ${managerIp}:2377
