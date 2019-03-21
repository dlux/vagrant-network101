#!/bin/bash

# Uncomment below interface to debug
# set -o xtrace

if [[ ! -f common_functions ]]; then
    curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions
fi

source common_functions
EnsureRoot
UpdatePackageManager

source /etc/os-release || source /usr/lib/os-release

nic="${1:-enp0s8}"
mode="${2:-dhcp}"
address="${3:-192.168.1.1}"
netmask="${4:-255.255.255.240}"
cidr="${5:-28}"

echo "<--- SET INTERFACE $nic to MODE $mode"

# Process on Ubuntu Xenial Distro
if [[ $VERSION_CODENAME == 'xenial' ]]; then
    text="\nauto $nic\niface $nic inet $mode"
    if [[ $mode != 'dhcp' ]]; then
        text="$text\naddress $address\nnetmask $netmask"
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
    text="DEVICE=$nic\nBOOTPROTO=$mode\nTYPE=Ethernet\nONBOOT=yes"
    if [[ $mode != 'dhcp' ]]; then
        text="$text\nIPADDR=$address\nNETMASK=$netmask"
    fi
    echo -e "$text" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    systemctl restart network
fi

