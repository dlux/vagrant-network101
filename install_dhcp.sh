# ! /bin/bash

# Uncomment below line to debug
# set -o xtrace

curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions

source common_functions
EnsureRoot
UpdatePackageManager

#######  Process on Ubuntu  ######
nic=''enp0s8

if [[ $(IsXenial) == True ]]; then
    echo "<--- SET FIXED IP ON NIC $nic Xenial"
    cat <<EOF >> /etc/network/interfaces.d/50-cloud-init.cfg

auto $nic
iface $nic inet static
address 192.168.1.1
netmask 255.255.255.240
EOF
    ip addr flush dev $nic
    ifup $nic
fi
if [[ $(IsBionic) == True ]]; then
    echo "<--- SET FIXED IP ON NIC $nic BIONIC"
    cat <<EOF >> /etc/netplan/50-vagrant.yaml
---
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic:
      dhcp4: no
      addresses: [192.168.1.1/28]
EOF
    netplan apply
fi

if [[ $(IsUbuntu) == True ]]; then
    echo "<--- INSTALL DHCP PACKAGES"
    apt-get install -y isc-dhcp-server

    echo "<--- USE $nic AS DEFAULT DHCP INTERFACE"
    file='/etc/default/isc-dhcp-server'
    sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$nic\"/g" $file
    systemctl restart isc-dhcp-server
    echo "<--- CONFIGURE DHCP OPTIONS"
    cat <<EOF > /etc/dhcp/dhcpd.conf
ddns-update-style none;
default-lease-time 3600;
max-lease-time 7200;
authoritative;
log-facility local7;
option broadcast-address 192.168.1.15;
option routers 192.168.1.14;
subnet 192.168.1.0 netmask 255.255.255.240 {
        #option routers       192.168.1.1;
        option subnet-mask    255.255.255.240;
        range                 192.168.1.1     192.168.1.13;
}
EOF
    systemctl restart isc-dhcp-server
fi

####### Process on CentOS Distro ######
if [[ $ID == 'centos' ]]; then
    echo 'UNDER DEVELOPMENT'
fi

echo "<<--- DHCPSERVER SETUP COMPLETED"

