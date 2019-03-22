==================
vagrant-network101
==================

.. image:: https://travis-ci.com/dlux/vagrant-network101.svg?branch=master
    :target: https://travis-ci.com/dlux/vagrant-network101

A project to try out basic Network concepts: DHCP, DNS, PXE, iPXE, HTTP Boot

Exercise 1 - DHCP
-----------------

Bring up 4 VMs:

* (1) Server - DHCP - will provide DHCP services on private network 192.168.1.0/28

  * Subnet /28 has 16 hosts(14 usable):

    * NETWORK ID:    192.168.1.0

    * BROADCAST:     192.168.1.15

    * NETWORK RANGE: 192.168.1.1 - 192.168.1.14

    * DHCP IP:       192.168.1.1

    * NETMASK:       255.255.255.240

* (3) Servers - DHCP Clients. The private network on NIC2 will be configured by the DHCP. This means IP address assigned on NIC2 will be within the define DHCP range defined above.


Usage
~~~~~

.. code-block:: bash

  $ git clone https://github.com/dlux/vagrant-network101.git
  $ cd vagrant-network101
  $ vagrant up

  # VERIFY DHCP SERVER SETUP:
  $ vagrant ssh dhcpserver
  $ sudo systemctl status isc-dhcp-server
  $ exit

  # VERIFY DHCP IP ADDRESS ON CLIENT:
  $ vagrant ssh dhcpclient-1
  $ ip a


Exercise 2 - Adding DNS
----------------------------

Using base configuration from Exercise1.
A new VM is added to serve as the DNS - set to non autostart hence VM must be turn on manually.
Additionally consider using same DHCP machine to host DNS by running intall_dns script


Usage
~~~~~

.. code-block:: bash

  # TO ADD A DNS SERVER
  $ vagrant up dnsserver
  # ALSO MIGHT PREFER RUNNING install_dns.sh ON SAME DHCP SERVER VM

