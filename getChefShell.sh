#!/usr/bin/env bash
#
# GetChefShell
#
# Expected to be run from inside vagrant vm after a chef exec kitchen converge. typically used to debug chef recipe
# often helpful to scp to vagrant@localhost;~/bin; then echo "export PATH=$PATH:~/bin" > ~/.bashrc
# 
# Example: can be added to Vagrantfile
#
# config.vm.provision  "shell", inline: <<-SHELL
#      if [ -d ~/bin ]; then
#         echo "export PATH=$PATH:~/bin" > ~/.bashrc
#      else
#         mkdir ~/bin
#         echo "export PATH=$PATH:~/bin" > ~/.bashrc
#      if
# SHELL

# Check if chef recipe is specified
if [ $# -ne 1 ]; then
    echo "Usage: $0 <Please Enter Chef Recipe>"
    exit 1
fi
RECIPES=${1}

# check if already running, stop to reset
CZPID=$(ps -ef | grep chef-zero | egrep -v grep| awk -F' ' '{print $2}');
if [ -n "${CZPID}" ];then
     for i in ${CZPID}; do
         kill -9 ${i};
     done
fi

# Start chef-zero daemon
/opt/chef/embedded/bin/chef-zero -d > /tmp/chef-zero.log 2>&1 &

# Load Chef cookbooks
pushd /tmp/kitchen;
knife cookbook upload -a -c client.rb;

# Specify a environment specific vars if needed
#knife upload environments/local_dev.json -c client.rb; 

# Start chef interactive Shell
chef-shell -z -c client.rb -o "${RECIPES}"
