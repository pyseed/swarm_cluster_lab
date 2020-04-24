#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# registry host
echo " ${provisionDataIp} ${provisionDataHostname}" >> /etc/hosts
 
# status
echo /etc/hosts
