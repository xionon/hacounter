#!/usr/bin/env bash
set -e

echo "Provisioning baseline"

if [ ! `which curl` ]; then sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install curl vim -y; fi

if [[ ! `which ruby` ]] || [[ ! `which bundle` ]]
then
  sudo apt-get install -y ruby bundler
  cd /vagrant/counter
  bundle install
fi

if [ ! -e /usr/local/bin/consul ]
then
  sudo apt-get install unzip -y
  cd /tmp
  wget --quiet https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
  unzip 0.4.1_linux_amd64.zip
  sudo mv /tmp/consul /usr/local/bin/consul
fi
sudo mkdir -p /etc/consul.d

if [ ! -e /usr/local/bin/consul-template ]
then
  sudo apt-get install -y golang git
  export GOPATH=/tmp/go
  git clone https://github.com/hashicorp/consul-template.git /tmp/consul-template
  cd /tmp/consul-template
  make
  mv /tmp/consul-template/bin/consul-template /usr/local/bin/consul-template
fi
