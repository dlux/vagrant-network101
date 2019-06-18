# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.require_version ">= 1.8.4"

if not Vagrant.has_plugin?('vagrant-proxyconf')
    system 'vagrant plugin install vagrant-proxyconf'
    raise 'vagrant-proxyconf was installed but it requires to execute again'
end

Vagrant.configure(2) do |config|
    # Proxy configuration
    if ENV['http_proxy'] != nil
        config.proxy.http     = ENV['http_proxy']
        config.proxy.https    = ENV['https_proxy']
        config.proxy.no_proxy = ENV['no_proxy']
    end

    # Tight configuration to a good known box version
    config.vm.box_check_update = false
    config.vm.box = 'centos/7'
    #config.vm.box_version = '201812.27.0'
    interface = 'eth1'

    #interface = 'enp0s8'
    #config.vm.box = 'ubuntu/bionic64'
    #config.vm.box_version = '20190212.1.0'
    #config.vm.box = 'ubuntu/xenial64'
    #config.vm.box_version = '20181031.0.0'

    config.vm.define :dhcpserver do |svr|
        svr.vm.hostname = 'dhcpserver'
        svr.vm.network "private_network", ip: "5.5.5.5", auto_config: false
        svr.vm.provider 'virtualbox' do |v|
            v.customize ['modifyvm', :id, '--memory', 512 * 1 ]
            v.customize ["modifyvm", :id, "--cpus", 1]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_interface.sh'
            s.args = [interface, "static"]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'install_dhcp.sh'
            s.args = [interface]
        end
    end

    config.vm.define :dnsserver, autostart: false do |svr|
        svr.vm.hostname = 'dnsserver'
        svr.vm.network "private_network", ip: "5.5.5.5", auto_config: false
        svr.vm.provider 'virtualbox' do |v|
            v.customize ['modifyvm', :id, '--memory', 512 * 1 ]
            v.customize ["modifyvm", :id, "--cpus", 1]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_interface.sh'
            s.args = [interface, "dhcp"]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'install_dns.sh'
        end
    end

    config.vm.define :natserver, autostart: false do |svr|
        svr.vm.hostname = 'natserver'
        svr.vm.network "private_network", ip: "5.5.5.5", auto_config: false
        svr.vm.provider 'virtualbox' do |v|
            v.customize ['modifyvm', :id, '--memory', 512 * 1 ]
            v.customize ["modifyvm", :id, "--cpus", 1]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_interface.sh'
            s.args = [interface, "dhcp"]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_nat.sh'
            s.args = [interface]
        end
    end

    config.vm.define :pxeserver, autostart: false do |svr|
        svr.vm.hostname = 'pxeserver'
        svr.vm.network "private_network", ip: "5.5.5.5", auto_config: false
        svr.vm.provider 'virtualbox' do |v|
            v.customize ['modifyvm', :id, '--memory', 512 * 1 ]
            v.customize ["modifyvm", :id, "--cpus", 1]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_interface.sh'
            s.args = [interface, "dhcp"]
        end
        svr.vm.provision 'shell' do |s|
            s.path = 'set_pxe_fog.sh'
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
                s.args = [interface, "dhcp"]
            end
        end
    end
end
