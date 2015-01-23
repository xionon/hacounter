#!/usr/bin/env bash

set -e

echo "Provisioning app"

ip=$1
i=$2

sudo cp /vagrant/counter/app.json /etc/consul.d/agent/
sudo sed -i'' -e "s/\:id\:/app-$i/" /etc/consul.d/agent/app.json
sudo sed -i'' -e "s/\:ip\:/$ip/" /etc/consul.d/agent/app.json
sudo service consul restart

echo "BIND_ADDR=\"$ip\"" >> /tmp/.env
sudo foreman export upstart /etc/init -u vagrant --procfile /vagrant/counter/Procfile --env /tmp/.env --app counter

sudo service counter restart
