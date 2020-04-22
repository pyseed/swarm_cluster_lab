#!/bin/bash
# ./provision/docker.sh should be apply before this script
# registry will expose the default port 5000
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

mkdir /registry
docker run -d \
    --restart=always \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry \
    -p 5000:5000 \
    --name=registry \
    registry:latest
