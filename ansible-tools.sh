#!/usr/bin/env bash
#
# Author: Andrew Marentis <amarentis@gmail.com> 
# 
# 1. create a directory
# 2. git init
# 3. $0 create mynewplaybook
# 4. vagrant up
# 5. start adding more tasks in roles/mynewplaybook/tasks/main.yml
# 6. vagrant provision to run those changes

command=$1
playbookname=$2
scriptdir=$(pwd)

if [ $# -ne 2 ];then
     echo "Usage: $0 <commmand> <playbookname>"
     exit 1
fi


create_blank_playbook () {
# Create default ansible directory sctructure
mkdir -p ${scriptdir}/roles;
pbdirlist="defaults meta tasks templates tests vars handlers";
for i in $pbdirlist; do
    mkdir -p ${scriptdir}/roles/${playbookname}/${i};
    if [ "$i" == "templates" ];then
        echo "# Ansible Template" >> ${scriptdir}/roles/${playbookname}/${i}/${playbookname}.j2;
    else
        echo "---" >>${scriptdir}/roles/${playbookname}/${i}/main.yml;
    fi
done

mkdir -p ${scriptdir}/inventories

# create default host entry for vagrant vm in the 
echo 'default ansible_ssh_host=127.0.0.1 ansible_ssh_port=2222 ansible_user=vagrant ansible_host=127.0.0.1' >${scriptdir}/inventories/local_dev

mkdir -p ${scriptdir}/module_utiles

cat <<EOF >> ${scriptdir}/Vagrantfile
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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "bento/ubuntu-14.04"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "site.yml"
    ansible.inventory_path = "inventories/local_dev"
  end
end

EOF

cat <<EOF >> site.yml
- hosts: all
  remote_user: root
  #become: yes
  #become_method: sudo
  pre_tasks:
      - name: 'install python2'
        raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)
        when: "ansible_distribution == 'Ubuntu'"

  roles:
     - ${playbookname}
EOF

}


case $command in 
       create)
         create_blank_playbook $playbookname
         ;;
       *)
         echo "Usage: $0 <commmand> <playbookname>"
         ;;
esac
