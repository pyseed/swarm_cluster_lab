#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

docker swarm init --advertise-addr ${managerIp}
