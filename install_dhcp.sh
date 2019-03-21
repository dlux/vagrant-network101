# ! /bin/bash

# Uncomment below line to debug
# set -o xtrace

curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions

source common_functions
EnsureRoot
UpdatePackageManager

function configure_dhcp {
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
        option subnet-mask    255.255.255.240;
        range                 192.168.1.2     192.168.1.13;
}
EOF
}

#######  Process on Ubuntu  ######
nic="${1:-enp0s8}"

if [[ $(IsUbuntu) == True ]]; then
    echo "<--- INSTALL DHCP PACKAGES"
    apt-get install -y isc-dhcp-server

    echo "<--- USE $nic AS DEFAULT DHCP INTERFACE"
    file='/etc/default/isc-dhcp-server'
    sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$nic\"/g" $file
    systemctl restart isc-dhcp-server
    configure_dhcp
    systemctl restart isc-dhcp-server
fi

####### Process on CentOS Distro ######
if [[ $(IsCentos) == True ]]; then
    yum -y install dhcp
    echo "DHCPDARGS=$nic" >> /etc/sysconfig/dhcpd
    configure_dhcp
    systemctl start dhcpd
    systemctl enable dhcpd
fi

echo "<<--- DHCPSERVER SETUP COMPLETED"

