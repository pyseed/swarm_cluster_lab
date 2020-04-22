#!/bin/bash
# WIP

cd /stack

# traefik
cd proxy
docker network create -d overlay proxy
docker stack deploy -c stack.yml proxy
docker service ps proxy_traefik
