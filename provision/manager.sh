. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q git tar vim

# swarm init
docker swarm init --advertise-addr ${managerIp}
docker node ls
