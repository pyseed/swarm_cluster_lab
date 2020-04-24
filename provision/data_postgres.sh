#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

echo 'run postgres ${postgresVersion}'
mkdir -p /data/pgdata
docker run -d \
    --restart=always \
    --name=postgres \
    -e POSTGRES_PASSWORD=postgres \
    --network=host \
    -v /data/pgdata:/var/lib/postgresql/data \
    postgres:${postgresVersion}
docker ps
