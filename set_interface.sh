#!/bin/bash

# Uncomment below interface to debug
# set -o xtrace

# Ensure script is run as root
if [ "$EUID" -ne "0" ]; then
   echo  "This script must be run as root."
   exit 1
fi

source /etc/os-release || source /usr/lib/os-release

# Process on Ubuntu Distro
if [[ $ID == 'ubuntu' ]]; then
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

# Process on CentOS Distro
if [[ $ID == 'centos' ]]; then
    echo 'UNDER DEVELOPMENT'
fi
