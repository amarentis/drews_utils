#!/usr/bin/env bash

#sudo apt-get update
#sudo apt-get install pgp -y
#sudo sh -c "curl -O https://get.docker.com/gpg | apt-key add -"
#sudo sh -c "wget https://get.docker.com/gpg; cat gpg | apt-key add -"
#sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
#sudo sh -C "sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable -y"
#sudo apt-get install software-properties-common lxc-docker python-pip awscli -y
#sudo apt-add-repository ppa:ansible/ansible
#sudo apt-get update
#sudo apt-get install ansible vagrant
#vagrant plugin install vagrant-hostmanager vagrant-aws vagrant-flow vagrant hosts vagrant-omnibus vagrant-reload
#sudo pip install --upgrade pip
#sudo pip install docker-py
#sudo apt-get install awscli -y
#sudo /usr/bin/aws ecr get-login --no-include-email >/tmp/ecslogin
#sudo pip install awscli boto3 --upgrade --user


#VARS
scriptdir=$(pwd)
playbookname=devopssetup


# Functions
function ansible_install {
	sudo apt-get update
	sudo apt-add-repository ppa:ansible/ansible -y
	sudo apt-get update
	sudo apt-get install ansible -y
}

# Generate Ansible ansible-playbook
cat <<EOF >${scriptdir}/${playbookname}.yml
---
# Ansible Config Script
- hosts: all
  tasks:
  - name: Update APT package cache
    apt:
     update_cache: no
    when: "ansible_distribution == 'Ubuntu'"

  - name: Adding Docker key 
    apt_key: 
      url: https://get.docker.com/gpg
      state: present
    when: "ansible_distribution == 'Ubuntu'"  

  - name: Adding Docker Repo
    apt_repository:
      repo: deb http://get.docker.io/ubuntu docker main
      state: absent
    when: "ansible_distribution == 'Ubuntu'"  

  - name: Adding google chrome key
    apt_key:
      url: https://dl-ssl.google.com/linux/linux_signing_key.pub
      state: present
    when: "ansible_distribution == 'Ubuntu'"  

  - name: Add google chrome repo
    apt_repository:
      repo: deb http://dl.google.com/linux/chrome/deb/ stable main
      state: present
    when: "ansible_distribution == 'Ubuntu'"  

  - name: Ubuntu16 Install software-properties-common lxd lxd-client lxc-docker git google-chrome-stable libcurl3 maven python-pip firefox etc. 
    apt: name={{item}} state=present
    with_items:
         - software-properties-common
         - lxd
         - lxd-client
         #- lxc-docker
         - git
         - libcurl3
         - maven
         - python-pip
         - firefox
         - google-chrome-stable
         - nmap
         - emacs24-nox
    when: (ansible_distribution == "Ubuntu" and ansible_distribution_version == "16.04") 

  - name: Ubuntu18 Install software-properties-common lxd lxd-client lxc-docker git google-chrome-stable libcurl3 maven python-pip firefox etc. 
    apt: name={{item}} state=present
    with_items:
         - software-properties-common
         - lxd
         - lxd-client
         - emacs25-nox
         - git
         - libcurl3
         - maven
         - python-pip
         - firefox
         - google-chrome-stable
         - nmap     
    when: (ansible_distribution == "Ubuntu" and ansible_distribution_version == "18.04")

  - name: Install vagrant
    apt:
      deb: https://releases.hashicorp.com/vagrant/2.1.4/vagrant_2.1.4_x86_64.deb
      #state: installed
    when: "ansible_distribution == 'Ubuntu'"

  - name: Install Vagrant plugins
    command: "vagrant plugin install {{item}}"
    with_items:
         - vagrant-hostmanager
         - vagrant-aws 
         - vagrant-flow
         - vagrant-hosts
         - vagrant-omnibus 
         - vagrant-reload

  - name: Add Java repository to sources
    apt_repository:
      repo: 'ppa:webupd8team/java'
    when: "ansible_distribution == 'Ubuntu'"

  - name: Autoaccept license for Java
    shell: echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    when: "ansible_distribution == 'Ubuntu'"

  - name: Update APT package cache
    apt:
     update_cache: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Install Java 8
    apt:
      name: oracle-java8-installer
      state: latest
      install_recommends: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Set Java 8 Env
    apt:
      name: oracle-java8-set-default
      state: latest
      install_recommends: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Install Amazon AWS Command Line Tools
    apt:
      name: awscli
      state: latest
      install_recommends: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Install unzip
    apt:
      name: unzip
      state: present
      force: yes
    when: "ansible_distribution == 'Ubuntu'"

  # Start Pip installs
  - name: upgrade pip
    pip:
       name: pip
       state: latest

  - name: Install docker-py
    pip:
      name: docker-py
      state: present
      version: 1.7.0

  - name: Install AWS CommandLine Tools to latest
    pip:
      name: awscli
      state: present

  - name: Install Boto
    pip:
      name: boto3
      state: latest    

# Download and install Hashicorp Tools
  - name: create {{ansible_env.HOME}}/bin if missing
    file: 
      path: "{{ansible_env.HOME}}/bin"
      state: directory
      recurse: true
      mode: 0755
    when: "ansible_distribution == 'Ubuntu'"

  # - name: "Test for {{ansible_env.HOME}}/bin in path"
  #   shell: "grep {{ansible_env.HOME}}/bin {{ansible_env.HOME}}/.bashrc"
  #   register: bin_grep
  #   when: "ansible_distribution == 'Ubuntu'"

  - name: "add {{ansible_env.HOME}}/bin to path"
    lineinfile: 
      dest: "{{ansible_env.HOME}}/.bashrc"
      line: "PATH={{ansible_env.PATH}}:{{ansible_env.HOME}}/bin"
    #when: bin_grep.stdout != ""  

  - name: Download Terraform
    unarchive: 
        src: "https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip"
        dest: "{{ansible_env.HOME}}/bin"
        remote_src: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Download Sublime-Text
    unarchive:
        src: "https://download.sublimetext.com/sublime_text_3_build_3176_x64.tar.bz2"
        dest: "{{ansible_env.HOME}}/bin"
        remote_src: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: Link Sublime Test bin in bin
    file:
        src: "{{ansible_env.HOME}}/bin/sublime_text_3/sublime_text"
        path: "{{ansible_env.HOME}}/bin/sublime_text"
        state: link
    when: "ansible_distribution == 'Ubuntu'"

  - name: Add sublime text desktop icon
    file:
        src: "{{ansible_env.HOME}}/bin/sublime_text_3/sublime_text.desktop"
        path: "/usr/share/applications/sublime_text.desktop"
        state: link
    when: "ansible_distribution == 'Ubuntu'"

  - name: Download IntelliJ OpenSource
    unarchive:
        src:  "https://download.jetbrains.com/idea/ideaIC-2018.2.4.tar.gz"
        dest: "{{ansible_env.HOME}}/bin"     
        remote_src: yes
    when: "ansible_distribution == 'Ubuntu'"

  - name: link idea-IC
    file:
        src: "{{ansible_env.HOME}}/bin/idea-IC-182.4505.22/bin/idea.sh"
        dest: "{{ansible_env.HOME}}/bin/idea.sh"
        state: link

  - name: Add ~/bin to Path
    lineinfile:
       path: "{{ansible_env.HOME}}/.bashrc"
       line: "PATH=$PATH:{{ansible_env.HOME}}/bin"
EOF

#  Run ansible

if [ -e /vagrant/${playbookname}.retry ];then  
	sudo ansible-playbook -i "localhost," -c local /vagrant/${playbookname}.yml --limit @/vagrant/${playbookname}.retry
else
	if [ -e /vagrant/${playbookname}.yml ];then
        if [ ! -e /usr/bin/ansible ];then 
           ansible_install
        fi   
        sudo ansible-playbook -i "localhost," -c local /vagrant/${playbookname}.yml
    else
        if [ ! -e /usr/bin/ansible ];then 
           ansible_install
        fi  
    	  sudo ansible-playbook -i "localhost," -c local ${scriptdir}/${playbookname}.yml
    fi
fi
