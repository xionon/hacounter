#!/usr/bin/env bash
set -e

echo "Provisioning consul_node"

ip=$1

sudo mkdir -p /etc/consul.d/agent
sudo cp /vagrant/scripts/templates/consul_node_config.json /etc/consul.d/agent/config.json
sudo sed -i'' -e "s/\:ip\:/$ip/" /etc/consul.d/agent/config.json

sudo foreman export upstart /etc/init --procfile /vagrant/consul/Procfile.consul-agent --user vagrant --app consul
sudo service consul restart
