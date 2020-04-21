export DEBIAN_FRONTEND=noninteractive
apt-get update -y -q

# silent upgrade
apt-get -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
