#!/usr/bin/env bash
set -e

echo "Provisioning haproxy"

if [ ! `which haproxy` ]
then
  sudo apt-get install -y haproxy
fi

sudo cp /vagrant/proxy/proxy.json /etc/consul.d/agent/
sudo service consul restart
echo "ENABLED=1" > /etc/default/haproxy

sudo foreman export upstart /etc/init -u root --procfile /vagrant/proxy/Procfile.haproxy --app proxy
sudo service proxy restart
