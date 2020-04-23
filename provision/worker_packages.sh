#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q vim
