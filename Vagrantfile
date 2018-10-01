# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  #
	config.hostmanager.enabled = true
	config.hostmanager.manage_guest = true
	config.vm.define "ubuntu16", autostart: false do |ubuntu16|
	    ubuntu16.vm.provider "virtualbox"
	    ubuntu16.vm.box = "bento/ubuntu-16.04"
	    ubuntu16.vm.hostname = "ubuntu16"
	    #ubuntu16.vm.network "forwarded_port", guest: 5432, host: 5433, auto_correct: true
	    ubuntu16.vm.network :private_network, ip: "192.168.240.9", dns: "8.8.8.8"
	    ubuntu16.vm.provision "shell", path: "./devenvInstall.sh"
	    # ubuntu16.vm.provision "ansible" do |ansible|
	    #   ansible.verbose = "v"
	    #   ansible.playbook = "site.yml"
	    #   #ansible.inventory_path = "inventories/local_dev"
	    #   ansible.limit = "ubuntu16"
	    #   #ansible.raw_arguments = ["--connection=paramiko"]
	    #   ansible.host_vars = {
	    #       "ubuntu16" => {"zabbixserver" => "192.168.240.5,127.0.0.1",
	    #                    "zabbixactiveserver" => "192.168.240.5,127.0.0.1"}
	    #   }
	    #   ansible.groups = {
	    #       "linux" => ["ubuntu16"],
	    #       "linux:vars" => {"zabbixserver" => "192.168.240.5,127.0.0.1",
	    #                        "zabbixactiveserver" => "192.168.240.5,127.0.0.1",
	    #                        "hostname" => "ubuntu16"}
	    #   }
	    # end
	end

	config.vm.define "win10x64", autostart: false do |win10x64|
	    win10x64.vm.provider "virtualbox"
	    win10x64.vm.box = "chusiang/win10-x64-ansible"
	    #                              win2012r2-x64-nocm
	    win10x64.vm.hostname = "win10x64"
	    #win10x64.vm.network "forwarded_port", guest: 5432, host: 5433, auto_correct: true
	    win10x64.vm.network :private_network, ip: "192.168.240.14", dns: "8.8.8.8"
	    
	    win10x64.vm.communicator = "winrm"
	    win10x64.vm.guest = :windows
	    win10x64.winrm.username = "IEUser"
	    win10x64.winrm.password = "Passw0rd!"
	    win10x64.vm.network "forwarded_port", host: 33389, guest: 3389, auto_correct: true
	    win10x64.vm.network "forwarded_port", host: 5985, guest: 5985, id: "winrm", auto_correct: true
	    win10x64.vm.network "forwarded_port", host: 5986, guest: 5986, auto_correct: true
        #
        # Run Windows Devsetup.bat
        #
        win10x64.vm.provision "shell", path: "devenvInstall.bat"
        #
        win10x64.vm.provision "shell", path: "devsetup.bat"

	#
	    # reboot After MSSQL Install
	    # win10x64.vm.provision "shell", inline: <<-SHELL
	    #      choco install -y sql-server-2017
	    # SHELL
	    # config.vm.provision :reload
	    #
	    # win10x64.vm.provision "ansible" do |ansible|
	    #   ansible.verbose = "v"
	    #   ansible.playbook = "site.yml"
	    #   #ansible.inventory_path = "inventories/local_dev"
	    #   ansible.limit = "win10x64"
	    #   #ansible.raw_arguments = ["--connection=paramiko"]
	    #   ansible.host_vars = {
	    #       "zbxagtW2008r2" => {"ansible_port" => "5986",
	    #                           "ansible_connection" => "winrm",
	    #                           "ansible_winrm_server_cert_validation" => "ignore",
	    #                           "ansible_winrm_transport" => "ntlm",
	    #                           "zabbixserver" => "192.168.240.5,127.0.0.1",
	    #                           "zabbixactiveserver" => "192.168.240.5,127.0.0.1"}
	    #   }
	    #   ansible.groups = {
	    #       "windows" => ["win10x64"],
	    #       "windows:vars" => {"zabbixserver" => "192.168.240.5,127.0.0.1",
	    #                          "zabbixactiveserver" => "192.168.240.5,127.0.0.1",
	    #                          "hostname" => "win10x64"}
	    #   }
	    # end
	end
end  
