# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.require_version ">= 1.8.4"

Vagrant.configure(2) do |config|
    # Tight configuration to a good known box version
    config.vm.box = 'ubuntu/xenial64'
    config.vm.box_version = '20181031.0.0'
    config.vm.box_check_update = false

    config.vm.define :dhcpserver do |svr|
        svr.vm.hostname = 'dhcpserver'
        svr.vm.network "private_network", ip: "5.5.5.5", auto_config: false
        svr.vm.provider 'virtualbox' do |v|
            v.customize ['modifyvm', :id, '--memory', 1024 * 2 ]
            v.customize ["modifyvm", :id, "--cpus", 1]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'install_dhcp.sh'
        end
    end

    # DEFINE 3 CLIENTS TO TEST DHCP - USE PORT 68
    (1..3).each do |i|
        config.vm.define "dhcpclient-#{i}" do |cli|
            cli.vm.network "private_network", ip: "5.5.5.5", auto_config: false
            cli.vm.provider 'virtualbox' do |v|
                v.customize ['modifyvm', :id, '--memory', 512 * 1 ]
                v.customize ["modifyvm", :id, "--cpus", 1]
            end
            cli.vm.provision 'shell' do |s|
                s.path = 'set_interface.sh'
            end
        end
    end
end
