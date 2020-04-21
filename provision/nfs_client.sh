. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

# packages
apt-get update -y -q
apt-get install -y -q nfs-common

# mount point
mkdir ${provisionNfsClientMountPoint}
echo " ${provisionNfsServerIp} ${provisionNfsServerHostname}" >> /etc/hosts
echo "${provisionNfsServerHostname}:/storage/ ${provisionNfsClientMountPoint} nfs rw 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
 
# status
echo /etc/hosts
ls -lah ${provisionNfsClientMountPoint}
