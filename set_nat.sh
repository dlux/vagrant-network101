#!/bin/bash

# Uncomment below line to debug
set -o xtrace

log_file=NAT_SETUP.log

curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions

source common_functions
EnsureRoot
UpdatePackageManager

priv_interface="$1"
## TODO: FIX NEXT LINE
pub_interface=$(ip route get 8.8.8.8 | awk '{ print $(NF-2); exit}')

function config_nat_firewalld {
    WriteLog "Setting up NAT server via firewalld service - DNAT IP forwarding"
    WriteLog "Enable firewalld"
    systemctl start firewalld

    WriteLog "Enable ipv4 forwarding"
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

    WriteLog "Remove private interface from public zone"
    WriteLog "$(firewall-cmd --get-active-zones)"
    firewall-cmd --permanent --zone=public --remove-interface=$priv_interface

    WriteLog "Add private interface to internal zone"
    firewall-cmd --permanent --zone=internal --add-interface=$priv_interface
    WriteLog "$(firewall-cmd --get-active-zones)"

    WriteLog "Modify internal zone on config file to make change permanent"
    net_file="/etc/sysconfig/network-scripts/ifcfg-$priv_interface"
    sed -i "s/^ZONE.*$/ZONE=internal/g" $net_file

    WriteLog "Enable masquerade on internal zone"
    firewall-cmd --zone=internal --add-masquerade --permanent

    WriteLog "Get existing rules"
    _rules=($(firewall-cmd --permanent --direct --get-all-rules))

    WriteLog "Apply firewalld direct rules"
    cmd='firewall-cmd --permanent --direct --add-rule ipv4'
    $cmd nat POSTROUTING 0 -o $pub_interface  -j MASQUERADE
    $cmd filter FORWARD 0 -i $priv_interface -o $pub_interface -j ACCEPT
    $cmd filter FORWARD 0 -i $pub_interface -o $priv_interface -m state \
        --state RELATED,ESTABLISHED -j ACCEPT

    WriteLog "Make sure public net route is the default"
}

function config_nat_iptable {
    WriteLog "Setting up NAT server via iptable rules - DNAT IP forwarding"

    echo '1' > /proc/sys/net/ipv4/ip_forward
    WriteLog 'Loading iptables module'
    modprobe ip_tables
    modprobe ip_conntrack
    iptables -t nat -A POSTROUTING -o $pub_interface -j MASQUERADE
}

config_nat_firewalld

