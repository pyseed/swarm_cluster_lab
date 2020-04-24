#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

mkdir -p /data/registry
docker run -d \
    --restart=always \
    --name=registry \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data/registry \
    -p 5000:5000 \
    registry:latest
docker ps
