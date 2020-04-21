. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q nfs-kernel-server

# nfs volume
mkdir /data
echo "nfs server: ip: ${provisionNfsServerIp}, hostname: ${provisionNfsServerHostname}" > /data/readme.md
chown ${provisionGroup}:${provisionUser} /data

# exports
# all_squash tells nfs to proceed any uid/guid as anonuid/anongid (here vagrant user)
echo "/data ${provisionNfsClientRange}(rw,all_squash,anonuid=${provisionNfsServerAnonuid},anongid=${provisionNfsServerAnongid},sync,no_subtree_check)" >> /etc/exports
systemctl restart nfs-kernel-server

# status
systemctl status nfs-kernel-server
cat /etc/exports
ls -lah /data
