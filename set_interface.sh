#!/bin/bash

# Uncomment below interface to debug
# set -o xtrace

# Ensure script is run as root
if [ "$EUID" -ne "0" ]; then
    echo  "This script must be run as root."
    exit 1
fi

source /etc/os-release || source /usr/lib/os-release

# Process on Ubuntu Xenial Distro
if [[ $VERSION_CODENAME=='xenial' ]]; then
    nic='enp0s8'
    echo "<--- SET INTERFACE $nic TO DHCP"
    cat <<EOF >> /etc/network/interfaces.d/50-cloud-init.cfg

auto $nic
iface $nic inet dhcp
EOF
    ip addr flush dev $nic
    ifup $nic
    ip a

fi


# Process on Ubuntu Bionic Distro
if [[ $VERSION_CODENAME=='bionic' ]]; then
    nic='enp0s8'
    echo "<--- SET FIXED IP ON NIC $nic"
    cat <<EOF >> /etc/netplan/50-vagrant.yaml
---
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic:
      dhcp4: yes
EOF
    netplan apply
fi

# Process on CentOS Distro
if [[ $ID == 'centos' ]]; then
    echo 'UNDER DEVELOPMENT'
fi

