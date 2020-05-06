#!/bin/bash

# Uncomment below interface to debug
set -o xtrace

set -e

[[ -z "${1}" ]] && echo 'must provide interface' && exit 1

nic="${1}"
address="${2}"
cidr="${3}"
[[ -z "$address" ]] && mode='dhcp' || mode='static'

if [[ ! -f common_functions ]]; then
    curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions
fi

source common_functions
EnsureRoot
UpdatePackageManager

source /etc/os-release || source /usr/lib/os-release

echo "<--- SET INTERFACE $nic to MODE $mode"

# Process on Ubuntu Xenial Distro
if [[ $VERSION_CODENAME == 'xenial' ]]; then
    # Get netmask mask
    apt-get install -y ipcalc
    export $(ipcalc -m ${address}/${cidr})

    text="\nauto $nic\niface $nic inet $mode"
    if [[ $mode != 'dhcp' ]]; then
        text="$text\naddress $address\nnetmask $NETMASK"
    fi
    echo -e "$text" >> /etc/network/interfaces.d/50-cloud-init.cfg

    ip addr flush dev $nic
    ifup $nic
    ip a
fi

# Process on Ubuntu Bionic Distro
if [[ $VERSION_CODENAME == 'bionic' ]]; then
    text="---\nnetwork:\n  version: 2\n  renderer: networkd\n  ethernets:"
    text="$text\n    $nic:"
    if [[ $mode == 'dhcp' ]]; then
        text="$text\n      dhcp4: yes"
    else
        text="$text\n      dhcp4: no\n      addresses: [$address/$cidr]"
    fi
    echo -e "$text" >> /etc/netplan/50-vagrant.yaml
    netplan apply
fi

# Process on CentOS7
if [[ $ID == 'centos' && $VERSION_ID == '7' ]]; then
    # Get network
    yum install -y initscripts
    export $(ipcalc -m ${address}/${cidr})

    text="DEVICE=$nic\nBOOTPROTO=$mode\nTYPE=Ethernet\nONBOOT=yes"
    if [[ $mode != 'dhcp' ]]; then
        text="$text\nIPADDR=$address\nNETMASK=$NETMASK"
    fi
    echo -e "$text" > /etc/sysconfig/network-scripts/ifcfg-eth1
    ifdown $nic
    ifup $nic
fi

