#!/usr/bin/env bash
set -e

echo "Provisioning consul_server"

ip=$1

sudo mkdir -p /etc/consul.d/server
sudo cp /vagrant/scripts/templates/consul_server_config.json /etc/consul.d/server/config.json
sudo sed -i'' -e "s/\:ip\:/$ip/" /etc/consul.d/server/config.json

cd /tmp
sudo mkdir -p /var/lib/consul
wget --quiet https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip
unzip 0.4.1_web_ui.zip
sudo mv dist /var/lib/consul/web_ui
sudo chown -R vagrant:vagrant /var/lib/consul

sudo foreman export upstart /etc/init --procfile /vagrant/consul/Procfile.consul-server --user vagrant --app consul
sudo service consul restart
