#!/bin/bash

cd /stack

# traefik
cd proxy
docker network create -d overlay proxy
docker stack deploy -c stack.yml proxy
cd ..

# portainer
cd portainer
mkdir -p /mnt/storage/volumes/portainer/data
docker stack deploy -c stack.yml portainer
cd ..
