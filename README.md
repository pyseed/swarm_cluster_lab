# swarm_cluster_lab

a vagrant (virtualbox provider) cluster composed of following nodes (ubuntu 18.04):

- storage: share between nodes a nfs access and a docker registry (for local builds)
- 1 manager (candidate to deploy traefik (swarm api access))
- 2 workers

hostnames:
- storage
- registry (by default an alias of storage)
- manager1
- worker1
- worker2

each manager/worker has access to 'storage' and 'registry' hosts.

## getting started

```
vagrant box update
```

feel free to use defaults or customize ./provision.env and ./Vagrantfile. You can set: IPs, storage hostname and mount point, registry location and its host alias, manager(s), worker(s), ...

before vagrant up, feel free to bind your own stack (in manager vms as /stack), specifying host path with:

```
export SCL_STACK=$HOME/mystack
```

if SCL_STACK is not set, default stack bootstrap example from ./stack directory of current repository will be bind.

```
vagrant up
vagrant halt
vagrant snapshot save up

vagrant up
vagrant ssh manager1
```

from the manager1 session you can:

- browse shared nfs storage in /mnt/storage
- use the docker registry: registry:5000


### stack bootstrap example

read ./stack/README.md for stack instructions

## manager1 host port forwarding

to support traefik use cases, manager1 forwards ports:

- 80 to 9080: traefik routes, url such like portainer.localhost:9080
- 8080 to 9088: traefik UI, alias of MANAGER1_IP:8080 (default 10.0.10.21:8080)

## how to bind a persistent volume to storage node

storage node provides a nfs shared access, to bind persistent volumes data through nodes.

**WARNING**: do not bind any database data on nfs, too low iops ! instead bind/volume locally with a constraint to keep service on the related node (fast iops).

### bootstrap a service storage volume:

assuming [service] is the service name

```
vagrant ssh manager1

$ mkdir -p /media/storage/volumes/[service]/myvolume
```

**WARNING**: do not bind directly on /media/storage/ as nfs storage is generic and not dedicated only to docker volumes)

### compose file service volume declaration:

```
volumes:
  myvolume:
    driver_opts:
      type: nfs
      o: "addr=storage,rw,nolock,soft,exec"
      device: ":/storage/volumes/[service]/myvolume"
```

device points to absolute local path in addr host itself

## registry

each node can push any 'local cluster' builds to the registry:

- hostname 'registry'
- port: 5000

```
curl http://registry:5000/v2/_catalog
```

## ctop

'ctop' command, for containers status, is available on each nodes.
