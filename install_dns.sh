#!/bin/bash

curl -OL https://github.com/dlux/InstallScripts/raw/master/common_functions

source common_functions
EnsureRoot
UpdatePackageManager

echo '<--- INSTALLING DNS --'
apt-get install -y bind9 dnsutils

echo '<--- CONFIGURING DNS SERVER'
echo '     SAME SERVER AS CACHING NAME SERVER, PRIMARY AND SECONDARY MASTERS'




