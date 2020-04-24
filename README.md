# swarm_cluster_lab

a vagrant (virtualbox provider) cluster composed of following nodes (ubuntu 18.04):

- storage: shared nfs file system: emulates distributed files and cluster persistent docker volumes
- data: common docker registry for build, AND emulates any 'managed' database system 
- 1 manager (candidate to deploy traefik (swarm api access))
- 2 workers (optional) (default)

hostnames:
- storage
- data
- registry (by default an alias of data)
- manager1, ..., manangerN
- worker1, ..., worker?

each manager/worker has access to 'storage' and 'registry' hosts.

## getting started

```
vagrant box update
```

feel free to use defaults or customize: provision.env, ./Vagrantfile and provisioning scripts in ./provision directory.

you can customize:

- count of managers/workers using MANAGERS/WORKERS in vagrant file
- private IPs
- storage hostname and mount point
- data hostname
- activate postgres using DATA_POSTGRES = true in vagrant file (default false)
- write your own data node provisioning (setup the database engine of your choice). add it to the data node: `provision_shell(data, "data_myscript.sh")`. there is an example script for postgres (provision/data_postgres.sh).
- registry location and its host alias
- or comment all workers: a single manager node to try swarm, using less resources, but using a pattern that will support more workers later with no change
- update or not the vagrant os with OS_UPDATE (default true)

### stack

before vagrant up, you can bind your own stack (in manager vms as /stack), specifying host path with:

```
export SCL_STACK=$HOME/mystack
```

if SCL_STACK is not set, default 'stack bootstrap' example from ./stack directory of current repository will be used.

### ram

ram (in Mo) can be set with following env vars:

- SCL_STORAGE_RAM (default 512)
- SCL_DATA_RAM (default 1024)
- SCL_MANAGER_RAM (default 1024)
- SCL_WORKER_RAM  (default 2048)

### cluster up

```
vagrant up
vagrant halt
vagrant snapshot save init

vagrant up
vagrant ssh manager1
```

from the manager1 session you can:

- browse shared nfs storage in /mnt/storage
- use the docker registry: registry:5000

### stack bootstrap example

read ./stack/README.md for stack instructions.

## manager1 host port forwarding

to support traefik use cases, manager1 forwards ports:

- 80 to 9080: traefik routes, url such like portainer.localhost:9080
- 8080 to 9088: traefik UI, alias of MANAGER1_IP:8080 (default 10.0.10.21:8080)

## how to bind a persistent volume to storage node

storage node provides a nfs shared access, to bind persistent volumes data accross all nodes.

**WARNING**: do not bind any database data on nfs, too low iops ! instead use local bind/volumes inside the dedicated data node (fast iops).

### bootstrap a service storage volume:

assuming [service] is the service name:

```
vagrant ssh manager1

$ mkdir -p /media/storage/volumes/[service]/myvolume
```

**WARNING**: do not bind directly on /media/storage/, as nfs storage is generic and not dedicated only to docker volumes.

### compose file service volume declaration:

```
volumes:
  myvolume:
    driver_opts:
      type: nfs
      o: "addr=storage,rw,nolock,soft,exec"
      device: ":/storage/volumes/[service]/myvolume"
```

note: device points to absolute local path in addr host itself.

## registry

each node can push any 'local cluster' builds to the registry:

- hostname 'registry'
- port: 5000

```
curl http://registry:5000/v2/_catalog
```

## databases

write your own data node provisioning (setup the database engine of your choice). add it to the data node: `provision_shell(data, "data_myscript.sh")`.

there is an example script for postgres (provision/data_postgres.sh). activate postgres using POSTGRES = true in vagrant file.

## ctop

'ctop' command, for containers status, is available on each nodes.
