#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -q

# clean docker
apt-get remove -y -q docker docker-engine docker.io containerd runc

# get docker#!/bin/bash
apt-get install -y -q apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
curl -fsSL https://download.docker.com/linux/${provisionOs}/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${provisionOs} $(lsb_release -cs) stable"
apt-get update
apt-get install -y -q docker-ce docker-ce-cli containerd.io

# set daemon: public loop + increase bridge networks range (253 networks vs the default 31)
sed -i 's|-H fd://|-H fd:// -H tcp://0.0.0.0:2375|g' /lib/systemd/system/docker.service
echo '{ "default-address-pools": [ {"base": "172.17.0.0/16", "size": 24} ] }' > /etc/docker/daemon.json
chmod 0600 /etc/docker/daemon.json
systemctl daemon-reload && systemctl restart docker.service

# use docker non-root
usermod -aG docker vagrant
newgrp docker
echo "alias d='docker'" >> /home/${provisionUser}/.bashrc
echo "alias ctop='docker run --rm -ti --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest'" >> /home/${provisionUser}/.bashrc

# status
systemctl status docker.service
docker --version
docker run hello-world
