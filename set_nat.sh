#!/bin/bash

# Uncomment below line to debug
set -o xtrace

log_file=NAT_SETUP.log

curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions

source common_functions
EnsureRoot
UpdatePackageManager

function configure_server_nat {
    WriteLog "Enable firewalld"
    systemctl start firewalld

    WriteLog "Enable ipv4 forwarding"
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

    WriteLog "Remove private interface from public zone"
    WriteLog "For this exercise eth1"
    priv_interface=$(ip a |grep -o eth. |tail -1)
    pub_interface=$(ip a |grep -o eth. -m1)
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

configure_server_nat

