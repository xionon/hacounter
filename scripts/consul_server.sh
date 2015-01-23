#!/usr/bin/env bash
set -e

echo "Provisioning consul_server"

ip=$1

sudo mkdir -p /etc/consul.d/server
sudo cp /vagrant/scripts/templates/consul_server_config.json /etc/consul.d/server/config.json
sudo sed -i'' -e "s/\:ip\:/$ip/" /etc/consul.d/server/config.json

sudo foreman export upstart /etc/init --procfile /vagrant/consul/Procfile.consul-server --user vagrant --app consul
sudo service consul restart
