#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# registry host
echo " ${registryIp} ${registryHostname}" >> /etc/hosts
 
# status
echo /etc/hosts
curl http://${registryHostname}:5000/v2/_catalog
