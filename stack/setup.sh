#!/bin/bash

cd /stack

# proxu (traefik)
cd proxy
docker network create -d overlay proxy
docker stack deploy -c stack.yml proxy
cd ..

# admin (portainer)
cd admin
mkdir -p /mnt/storage/volumes/admin/portainer/data
docker stack deploy -c stack.yml admin
cd ..
