#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install pgp -y
sudo sh -c "curl -O https://get.docker.com/gpg | apt-key add -"
sudo sh -c "wget https://get.docker.com/gpg; cat gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo sh -C "sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable -y"
sudo apt-get install software-properties-common lxc-docker python-pip awscli -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible vagrant
vagrant plugin install vagrant-hostmanager vagrant-aws vagrant-flow vagrant hosts vagrant-omnibus vagrant-reload
sudo pip install --upgrade pip
sudo pip install docker-py
#sudo apt-get install awscli -y
#sudo /usr/bin/aws ecr get-login --no-include-email >/tmp/ecslogin
sudo pip install awscli boto3 --upgrade --user
