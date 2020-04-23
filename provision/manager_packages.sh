#!/bin/bash
. /tmp/provision.env
export DEBIAN_FRONTEND=noninteractive

apt-get update -y -q
apt-get install -y -q git tar tree vim wget
